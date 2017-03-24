#===============================================================================
#        Add a single folder in the src directory
#
#===============================================================================

# TODO: Split into multiple files

#----------------------------------------------------
function(add_isis_app folder libDependencies)

  # Folders: assets, tsts

  # The internal build name will be different than the output name
  # - This deals with problems compiling same-named targets on case-insensitive machines.
  get_filename_component(appName ${folder}  NAME)
  set(internalAppName ${appName}_app)
  message("Proccesing APP folder: ${folder}")

  # Find the source and header files
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  file(GLOB xmlFiles "${folder}/*.xml")
  
  # All the XML files need to be copied to the install directory
  # - They also need be put in the source folder for the app tests
  install(FILES ${xmlFiles} DESTINATION "${CMAKE_INSTALL_PREFIX}/bin/xml")
  file(COPY ${xmlFiles} DESTINATION ${CMAKE_SOURCE_DIR}/bin/xml)

  # Generate required QT files
  generate_moc_files(mocFiles ${folder})

  # Set up the executable 
  #message("Adding executable ${internalAppName}")
  add_executable(${internalAppName} ${headers} ${sources} ${mocFiles})
  set_target_properties(${internalAppName} PROPERTIES LINKER_LANGUAGE CXX)

  # Handle individual apps that have additional library requirements
  set(finalLibDeps ${libDependencies})
  if((${appName} STREQUAL "amicacal") OR (${appName} STREQUAL "findfeatures"))
    set(finalLibDeps ${finalLibDeps} ${OPENCVLIB})
  elseif(${appName} STREQUAL "cnet2dem")
    set(finalLibDeps ${finalLibDeps} ${NNLIB})
  endif()
  #message("finalLibDeps = ${finalLibDeps}")

  target_link_libraries(${internalAppName} ${finalLibDeps})
  # Have the app install with the real name, not the internal name.
  set_target_properties(${internalAppName} PROPERTIES OUTPUT_NAME ${appName})
  install(TARGETS ${internalAppName} DESTINATION bin)


  # Set up the app tests
  # - There may be multiple test folders in the /tsts directory, each
  #   with its own Makefile describing the test.

  set(testFolder ${folder}/tsts)
  file(GLOB tests "${testFolder}/*")
  foreach(f ${tests})
    add_makefile_test_folder(${f} ${appName})  
  endforeach()

endfunction(add_isis_app)

#----------------------------------------------------

# Add a unit test defined by a Makefile and specific input/output folders.
function(add_makefile_test_folder folder prefix_name)

    get_filename_component(subName ${folder} NAME)
    if("${subName}" STREQUAL "Makefile")
      return()
    endif()
    
    set(makeFile ${folder}/Makefile)
    
    # Figure out the input, output, and truth paths
    file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${folder})
    set(dataDir   ${ISIS3TESTDATA}/${relPath})
    set(inputDir  ${dataDir}/input)
    set(outputDir ${dataDir}/output) # TODO: Where to put this?
    set(truthDir  ${dataDir}/truth)
    set(testName ${prefix_name}_test_${subName})
    #message("dataDir = ${dataDir}")
    #message("makeFile = ${makeFile}")
    #message("testName = ${testName}")
 
    # Some tests don't need an input folder but the others must exist   
    if(NOT EXISTS ${makeFile})
      message(FATAL_ERROR "Required file does not exist: ${makeFile}")
    endif()
    if(NOT EXISTS ${truthDir})
      message(FATAL_ERROR "Required data folder does not exist: ${truthDir}")
    endif()

    #message( FATAL_ERROR "STOP." )
    add_makefile_test_target(${testName} ${makeFile} ${inputDir} ${outputDir} ${truthDir})

endfunction()

#----------------------------------------------------
# Set up the lone unit test in an obj folder
macro(make_obj_unit_test moduleName testFile truthFile reqLibs pluginLibs)

  # Get the object name (last folder part)
  get_filename_component(folder ${testFile} DIRECTORY)
  get_filename_component(filename ${folder} NAME)

  # See if there are any plugin libraries that match the name
  # - If there are, we need to link to them!
  set(matchedLibs)
  foreach (f ${pluginLibs})
    if(${f} STREQUAL ${filename})
      set(matchedLibs ${f})
      #message("Linking library ${matchedLibs} to test ${filename}")
    endif()
  endforeach()
  #message("matchedLibs = ${matchedLibs}")
  # Generate a name for the executable  
  set(executableName "test_${moduleName}_${filename}")

  #message("testfile = ${testFile}")
  #message("truthfile = ${truthFile}")
  #message("Adding executable = ${executableName}")

  # Create the executable and link it to the module library
  #message("link to ${moduleName}")
  add_executable( ${executableName} ${testFile}  )
  set(depLibs "${reqLibs};${matchedLibs}") # TODO: Check!
  #message("depLibs = ${depLibs}")
  target_link_libraries(${executableName} ${moduleName} ${depLibs}) # TODO: Check!
  #message( FATAL_ERROR "STOP." )

  # TODO: Make test build/installion optional!
  set(testFolder tests) # TODO: Where do the unit tests go??
  install(TARGETS ${executableName} DESTINATION ${testFolder})

  # Add this test to the unit test command
  add_unit_test_target(${executableName} ${truthFile})

endmacro()

#----------------------------------------------------
# Load information about a single obj folder
function(add_isis_obj folder reqLibs)

  # Includes the class, unit test app, and unit test truth result

  #message("Processing OBJ folder: ${folder}")

  get_filename_component(folderName ${folder} NAME)

  # Look inside this folder for include files
  include_directories(${folder})

  # Find the source and header files
  # TODO: Verify only one truth file!
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  file(GLOB truths  "${folder}/*.truth")
  file(GLOB plugins "${folder}/*.plugin")

  # Generate protobuf, ui, and moc files if needed.
  generate_protobuf_files(protoFiles ${folder})
  generate_ui_files(uiFiles ${folder})
  generate_moc_files(mocFiles ${folder})

  # Don't include the unit test in the main source list
  set(unitTest ${folder}/unitTest.cpp)
  list(REMOVE_ITEM sources "${unitTest}")

  # Add the unit test file for this folder if it exists.
  if(EXISTS "${unitTest}")
    set(thisTestFiles ${unitTest}) 
  else()
    set(thisTestFiles)  
  endif()


  # Output assignments are locally first so we can check them at the local scope.
  set(thisSourceFiles ${headers} ${sources} ${protoFiles} ${uiFiles} ${mocFiles})
  set(thisTruthFiles  ${truths} )
  
  # If there are multiple truth files, select based on the OS.
  list(LENGTH thisTestFiles numTest)
  list(LENGTH thisTruthFiles numTruth)
  if(NOT (${numTest} EQUAL ${numTruth}) )

    #message("UNEQUAL TEST!!!!!!")
    #message("Detected OS: ${osVersionString}")
    #message("testFiles = ${thisTestFiles}")
    #message("truths = ${thisTruthFiles}")

    # Look for a truth file that contains the OS string
    set(matchedTruth "NONE")
    foreach(truthFile ${thisTruthFiles})
      #message("Checking file ${truthFile}")
      # If the truth file contains the OS string, use it.
      string(FIND ${truthFile} ${osVersionString} position)
      if(NOT ${position} EQUAL -1)
        set(matchedTruth ${truthFile})
        break()
      endif()
      
    endforeach()
    
    # If no OS matched, use the default truth file.
    if(${matchedTruth} STREQUAL "NONE")
      set(matchedTruth "${folder}/${folderName}.truth")
    else()
      message("Selected OS truth file = ${matchedTruth}")
      #message( FATAL_ERROR "STOP." )
    endif()

    set(thisTruthFiles ${matchedTruth})
    #message("Selected truth file = ${thisTruthFiles}")
    #message( FATAL_ERROR "STOP." )
  endif()

  # Always pass the test and truth files to the caller
  set(newTestFiles   ${thisTestFiles}   PARENT_SCOPE)
  set(newTruthFiles  ${thisTruthFiles}  PARENT_SCOPE)
  
  list(LENGTH plugins numPlugins)
  if(${numPlugins} EQUAL 0)
    # No plugins, pass the source files back to the caller to add to
    #  the larger library.
    set(newSourceFiles ${thisSourceFiles} PARENT_SCOPE)
  else()
    # Folder with a plugin means that this is a separate library!
    # Add it here and then we are done with the source files.

    #message("Found plugins: ${plugins}")

    if(NOT (${numPlugins} EQUAL 1))
      message( FATAL_ERROR "Error: Multiple plugins found in folder!" )
    endif()

    get_filename_component(libName    ${folder}  NAME)
    get_filename_component(pluginName ${plugins} NAME)
    #message("Adding special library: ${libName}")
    #message("SOURCE FILES: ${thisSourceFiles}")

    add_library_wrapper(${libName} "${thisSourceFiles}" "${reqLibs}")

    # Append the plugin file to a single file in the build directory
    # where the .so files will be created.  During installation copy these
    # plugin files to the installation library folder.
    set(pluginPath ${CMAKE_BINARY_DIR}/src/${pluginName})
    #message("Appending plugin to ${pluginPath}")
    cat(${plugins} ${pluginPath})
    install(FILES ${pluginPath} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)

    # Record this library name for the caller
    set(newPluginLib ${libName}  PARENT_SCOPE)

  endif()


endfunction(add_isis_obj)


#----------------------------------------------------
# These are under [module]/tsts
function(add_isis_module_test folder)

  # Just contains a makefile
  message("TODO: Process module test folder: ${folder}")
  
  # These are probably similar to the app tests in how they are handled.

endfunction(add_isis_module_test)

#----------------------------------------------------

# Adds an entire module folder.
# - This includes the "base" folder and all the mission specific folders.
# - Each module will build into an entire library file!
function(add_isis_module name)

  # First argument is the module name.
  # Arguments after the first are the folders to look in.
  set(topFolders ${ARGN})

  message("Search program folders ${topFolders}")

  set(objFolders)
  set(appFolders)
  set(tstFolders)
  foreach(f ${topFolders})

    #message("Processing TOP FOLDER ${f}")

    # Folders: apps, lib, tests
    set(objsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/objs")
    set(appsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/apps")
    set(tstsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/tsts")

    # Start with the objs folder

    SUBDIRLIST(${objsDir} thisObjFolders)
    SUBDIRLIST(${appsDir} thisAppFolders)
    #SUBDIRLIST(${tstsDir} thisTstFolders)

    set(objFolders ${objFolders} ${thisObjFolders})
    set(appFolders ${appFolders} ${thisAppFolders})
    #set(tstFolders ${tstFolders} ${thisTstFolders})

  endforeach()

  # Now that we have the library info, call function to add it to the build!
  # - Base module depends on 3rd party libs, other libs also depend on base.
  # - Only the base module gets both a static and shared library.
  if(${name} STREQUAL ${CORE_LIB_NAME})
    set(reqLibs ${ALLLIBS})
    set(alsoStatic ON)
  else()
    set(reqLibs "${CORE_LIB_NAME};${ALLLIBS}")
    set(alsoStatic OFF)
  endif()
  
  set(sourceFiles)
  set(unitTestFiles)
  set(truthFiles)
  set(pluginLibs)
  foreach(f ${objFolders})
    set(newSourceFiles)
    set(newTestFiles)
    set(newTruthFiles)
    set(newPluginLib)
    add_isis_obj(${f} "${reqLibs}")
    set(sourceFiles   ${sourceFiles}   ${newSourceFiles})
    set(unitTestFiles ${unitTestFiles} ${newTestFiles})
    set(truthFiles    ${truthFiles}    ${newTruthFiles})
    set(pluginLibs    ${pluginLibs}    ${newPluginLib})
  endforeach(f)
  #message("Plugin libs: ${pluginLibs}")

  #message("Found app folders: ${APP_FOLDERS}")
  #message("Found obj folders: ${OBJ_FOLDERS}")
  #message("Found test folders: ${TST_FOLDERS}")
  #message("Found source files: ${sourceFiles}")

  # Some modules don't generate a library
  list(LENGTH sourceFiles temp)
  if (NOT ${temp} EQUAL 0)
    message("Adding library: ${name}")
    add_library_wrapper(${name} "${sourceFiles}" "${reqLibs}" ${alsoStatic})

    # Have the plugin libraries depend on the module library
    foreach(plug ${pluginLibs})
      target_link_libraries(${plug} ${name})
    endforeach()

    # For everything beyond the module library, require the module library.
    set(reqLibs "${reqLibs};${name}")
    #message("reqLibs = ${reqLibs}")
    #message( FATAL_ERROR "STOP." )

    # Now that the library is added, add all the unit tests for it.
    list(LENGTH unitTestFiles temp)
    math(EXPR numTests "${temp} - 1")
    #message("NUM_TESTS = ${numTests}")
    foreach(val RANGE ${numTests})
      list(GET unitTestFiles ${val} testFile )
      list(GET truthFiles    ${val} truthFile)
      #make_obj_unit_test(${name} ${testFile} ${truthFile} "${reqLibs}" "${pluginLibs}")
    endforeach()

  endif()
 
  # Process the apps
  foreach(f ${appFolders})
    # Apps always require the core library
    add_isis_app(${f} "${reqLibs}")
  endforeach()
  
  # Process the tests
  foreach(f ${tstFolders})
    add_isis_module_test(${f} ${appName})
  endforeach()  
  
endfunction(add_isis_module)







