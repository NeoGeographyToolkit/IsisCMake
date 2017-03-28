#==================================================================================
# This file contains small utility functions
#==================================================================================

# Copy one file
function(copy_file src dest)
  configure_file(${src} ${dest} COPYONLY)
endfunction()

# Copy one folder
function(copy_folder src dest)
  execute_process(COMMAND cp -r ${src} ${dest})
endfunction()

# Copy all files matching a wildcard to the output folder.
function(copy_wildcard wildcard outputFolder)
  file(GLOB files ${wildcard})
  file(COPY ${files} DESTINATION ${outputFolder})
endfunction()

# Copy all input files to the output folder
function(copy_files_to_folder files folder)
  foreach(f ${files})
    get_filename_component(filename ${f} NAME)
    set(outputPath "${folder}/${filename}")
    configure_file(${f} ${outputPath} COPYONLY)
  endforeach()
endfunction()

# Quit if the file does not exist
function(verify_file_exists path)
  if(NOT EXISTS ${path})
    message( FATAL_ERROR "Required file ${path} does not exist!" )
  endif()
endfunction()

# Set result to ON if the file contains "s", OFF otherwise.
function(file_contains path s result)
  file(READ ${path} contents)
  string(FIND "${contents}" "${s}" position)
  set(${result} ON PARENT_SCOPE)
  if(${position} EQUAL -1)
    set(${result} OFF PARENT_SCOPE)
  endif()
endfunction()


# Set result to a list of all the subdirectories in the given directory.
function(get_subdirectory_list curdir result)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    # Skip files and hidden folders.
    string(SUBSTRING ${child} 0 1 firstChar)
    if( (IS_DIRECTORY ${curdir}/${child}) AND (NOT ${firstChar} STREQUAL ".") )
      list(APPEND dirlist ${curdir}/${child})
    endif()
  endforeach()
  set(${result} ${dirlist} PARENT_SCOPE)
endfunction()

# Append the contents of IN_FILE to the end of OUT_FILE
function(cat inFile outFile)

  # If the output file does not exist, init with an empty file.
  if(NOT EXISTS "${outFile}")
    file(WRITE ${outFile} "")
  endif()

  # Perform the file concatenation.
  file(READ ${inFile} contens)
  file(APPEND ${outFile} "${contents}")
endfunction()

# Get the correct location to generate code for items in a given input folder
# - Generated code includes uic, moc, and protobuf files.
function(get_code_gen_dir inputFolder codeGenFolder)
  file(RELATIVE_PATH relPath ${PROJECT_SOURCE_DIR} ${inputFolder})
  set(${codeGenFolder} "${PROJECT_BINARY_DIR}/${relPath}" PARENT_SCOPE)
  file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/${relPath}")
  
  # Also add this folder to the include path
  include_directories("${PROJECT_BINARY_DIR}/${relPath}")
endfunction()

# Determine the text string used to describe this OS version
function(get_os_version text)
  
  if(UNIX AND NOT APPLE)
  
    # Fetch OS information
    execute_process(COMMAND cat "/etc/os-release"
                    OUTPUT_VARIABLE result
                    ERROR_VARIABLE result)
    #message("result = ${result}")
  
    # Extract OS name and version
    string(REGEX MATCH "NAME=[A-Za-z\"]+" name "${result}")
    string(REGEX MATCH "VERSION_ID=[0-9\\.\"]+" version "${result}")
    string(SUBSTRING ${name} 6 -1 name)
    string(SUBSTRING ${version} 12 -1 version)
    string(REPLACE "\"" "" name ${name})
    string(REPLACE "\"" "" version ${version})
    string(REPLACE "." "_" version ${version})
    #message("name = ${name}")
    #message("version = ${version}")

    set(prefix "Linux_x86_64_")
  
  # Build the final output string
  elseif(APPLE)

    # Fetch OS information
    execute_process(COMMAND sw_vers
                    OUTPUT_VARIABLE result
                    ERROR_VARIABLE result)

    # Format the string
    string(REGEX MATCH "[0-9]+.[0-9]+.[0-9]+" version "${result}")
    string(REGEX MATCH "^[0-9]+.[0-9]+" version "${version}")
    string(REPLACE "." "_" version ${version})
    
    set(name   "MacOSX")
    set(prefix "Darwin_")

  else()
    message( FATAL_ERROR "Did not recognize a supported operating system!" )
  endif()
  
  # Final string assembly
  set(${text} ${prefix}${name}${version} PARENT_SCOPE)
endfunction()

#------------------------------------------------------------

# Wrapper function to add a library and its components
function(add_library_wrapper name sourceFiles libDependencies)

  # The only optional argument is "alsoStatic", which indicates that
  #  the library should be build both shared and static.
  set(alsoStatic ${ARGN})

  # Add library, set dependencies, and add to installation list.
  add_library(${name} SHARED ${sourceFiles})
  set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX) 
  target_link_libraries(${name} ${libDependencies})
  install(TARGETS ${name} DESTINATION lib)
    
  #if(alsoStatic)
  if(OFF) # TODO TURN BACK ON!
    # The static version needs a different name, but in the end the file
    # needs to have the same name as the shared lib.
    set(staticName "${name}_static") 
    message("Adding static library ${staticName}")

    add_library("${staticName}" STATIC ${sourceFiles})
    set_target_properties(${staticName} PROPERTIES LINKER_LANGUAGE CXX) 
    target_link_libraries(${staticName} ${libDependencies})

    # Use a copy -> install combo to get the file to the correct place.
    add_custom_command(TARGET ${staticName} POST_BUILD 
                       COMMAND mv ${CMAKE_BINARY_DIR}/src/lib${staticName}.a
                                  ${CMAKE_BINARY_DIR}/src/lib${name}.a)

    install(CODE "EXECUTE_PROCESS(COMMAND cp ${CMAKE_BINARY_DIR}/src/lib${name}.a 
                                             ${CMAKE_INSTALL_PREFIX}/lib/lib${name}.a)")
  endif()


  # Set all the header files to be installed to the include directory
  foreach(f ${sourceFiles})
    get_filename_component(extension ${f} EXT)
    string( TOLOWER "${extension}" extensionLower )
    # Compare this file extension to list of accepted header file extensions
    if( extensionLower STREQUAL ".h" OR extensionLower STREQUAL ".hpp" OR extensionLower STREQUAL ".tcc")
      set(fullPath "${CMAKE_CURRENT_SOURCE_DIR}/${f}")
      INSTALL(FILES ${f} DESTINATION inc)
    endif()
  endforeach(f)

endfunction()


