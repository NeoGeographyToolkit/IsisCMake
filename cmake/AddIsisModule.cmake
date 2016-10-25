#===============================================================================
#        Add a single folder in the src directory
#
#===============================================================================

# TODO: Split into multiple files


#----------------------------------------------------
function(add_isis_app folder lib_dependencies)

# Folders: assets, tsts

  message("Proccesing APP folder: ${folder}")

  # Find the source and header files
  # TODO: Verify only one truth file!
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  
  # Set up the executable 
  add_executable(${app_name} "${headers} ${sources}")
  target_link_libraries(${app_name} ${lib_dependencies})
  install(TARGETS ${app_name} DESTINATION bin)

  # TODO: What to do with documentation files??
  
  # Set up the app tests

  # TODO: Where are the input and truth files?
  # TODO: Need to read in the make file contents!
  #       -> May need to write a python script to parse the makefiles!

endfunction(add_isis_app)

#----------------------------------------------------
# These are under [module]/apps/[app]/tsts
function(add_isis_app_test)

# Just contains a makefile

endfunction(add_isis_app_test)



#----------------------------------------------------
# Set up the lone unit test in an obj folder
# - Is there ever more than one file?
macro(make_obj_unit_test moduleName testFile truthFile)



  # Get file name without extension
  get_filename_component(filename ${truthFile} NAME_WE)
  
  # Generate a name for the executable  
  set(executableName "test_${moduleName}_${filename}")

  #message("testfile = ${testFile}")
  #message("truthfile = ${truthFile}")
  #message("executableName = ${executableName}")

  # Create the executable and link it to the module library
  #message("link to ${moduleName}")
  add_executable( ${executableName} ${testFile}  )
  target_link_libraries(${executableName} ${moduleName} ${ALLLIBS}) # TODO: Check!

  # TODO: Make test build/installion optional!
  install(TARGETS ${executableName} DESTINATION tests)

  # Add this test to the unit test command
  add_unit_test_target(${executableName} ${truthFile})

endmacro()

#----------------------------------------------------
# Load information about a single obj folder
function(add_isis_obj folder)

  # Includes the class, unit test app, and unit test truth result

  message("Processing OBJ folder: ${folder}")

  # Look inside this folder for include files
  include_directories(${folder})

  # Find the source and header files
  # TODO: Verify only one truth file!
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  file(GLOB truths  "${folder}/*.truth")

  # Generate protobuf and ui files if needed.
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

  #message("Found headers: ${headers}")


  # Output assignments are locally first so we can check them at the local scope.
  set(thisSourceFiles ${headers} ${sources} ${protoFiles} ${uiFiles} ${mocFiles})
  set(thisTruthFiles  ${truths} )

  
  # TODO: Choose the truth file based on the OS!!!!
  # Verify that the number of tests and truths are equal!
  list(LENGTH thisTestFiles numTest)
  list(LENGTH thisTruthFiles numTruth)
  if(NOT (${numTest} EQUAL ${numTruth}) )
    message("UNEQUAL TEST!!!!!!")
    message("testFiles = ${thisTestFiles}")
    message("truths = ${thisTruthFiles}")
    list(GET thisTruthFiles 0 thisTruthFiles )
    message("Selected truth file = ${thisTruthFiles}")
    #message( FATAL_ERROR "STOP." )
  endif()
  
  #set(thisSourceFiles ${headers} ${sources} ${protoFiles} ${uiFiles} PARENT_SCOPE)
  #set(thisTruthFiles  ${truths}  PARENT_SCOPE)
  set(thisTestFiles   ${thisTestFiles}   PARENT_SCOPE)
  set(thisSourceFiles ${thisSourceFiles} PARENT_SCOPE)
  set(thisTruthFiles  ${thisTruthFiles}  PARENT_SCOPE)

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

  message("topFolders = ${topFolders}")

  set(objFolders)
  set(appFolders)
  set(tstFolders)
  foreach(f ${topFolders})

    message("Processing TOP FOLDER ${f}")

    # Folders: apps, lib, tests
    set(objsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/objs")
    set(appsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/apps")
    set(tstsDir "${CMAKE_CURRENT_LIST_DIR}/${f}/tsts")

    # Start with the objs folder

    SUBDIRLIST(${objsDir} thisObjFolders)
    #SUBDIRLIST(${appsDir} thisAppFolders)
    #SUBDIRLIST(${tstsDir} thisTstFolders)

    set(objFolders ${objFolders} ${thisObjFolders})
    #set(appFolders ${appFolders} ${thisAppFolders})
    #set(tstFolders ${tstFolders} ${thisTstFolders})

  endforeach()

  # DEBUG - Start with one folder
  #set(objFolders ${objsDir}/Preference)
  #set(appFolders ${appsDir}/algebra )
  #set(tstFolders ${tstsDir}/CropCam2map )

  #message("objFolders = ${objFolders}")

  
  set(sourceFiles)
  set(unitTestFiles)
  set(truthFiles)
  foreach(f ${objFolders})
    set(thisSourceFiles)
    set(thisTestFiles)
    set(thisTruthFiles)
    add_isis_obj(${f})
    set(sourceFiles   ${sourceFiles}   ${thisSourceFiles})
    set(unitTestFiles ${unitTestFiles} ${thisTestFiles})
    set(truthFiles    ${truthFiles}    ${thisTruthFiles})
  endforeach(f)
  #list(SORT unitTestFiles)
  #list(SORT truthFiles)
  #message("All source files: ${sourceFiles}")
  #message("All test files: ${unitTestFiles}")
  #message("All truth files: ${truthFiles}")

  #message("Found app folders: ${APP_FOLDERS}")
  #message("Found obj folders: ${OBJ_FOLDERS}")
  #message("Found test folders: ${TST_FOLDERS}")

  # Now add the library in CMake
  add_library(${name} ${sourceFiles})

  set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)
  
  # Base module depends on 3rd party libs, other libs also depend on base.
  if(${name} STREQUAL "base")
    target_link_libraries(${name} "${ALLLIBS}")
  else()
    target_link_libraries(${name} "base ${ALLLIBS}")
  endif()

  # Mark library for installation
  install(TARGETS ${name} DESTINATION lib)


  # Set all the header files to be installed to the include directory
  foreach(f ${sourceFiles})
    get_filename_component(extension ${f} EXT) # Get file extension  
    string( TOLOWER "${extension}" extensionLower )
    if( extensionLower STREQUAL ".h" OR extensionLower STREQUAL ".hpp" OR extensionLower STREQUAL ".tcc")
      set(fullPath "${CMAKE_CURRENT_SOURCE_DIR}/${f}") # TODO: Check this!
      INSTALL(FILES ${f} DESTINATION include/${name})
    endif()
  endforeach(f)


  # Now that the library is added, add all the unit tests for it.
  list(LENGTH unitTestFiles temp)
  math(EXPR numTests "${temp} - 1")
  message("NUM_TESTS = ${numTests}")
  foreach(val RANGE ${numTests})
    list(GET unitTestFiles ${val} testFile )
    list(GET truthFiles    ${val} truthFile)
    make_obj_unit_test(${name} ${testFile} ${truthFile})
  endforeach()
  
  # Process the apps
  foreach(f ${appFolders})
    #add_isis_app(${f})
  endforeach()
  
  # Process the tests
  foreach(f ${tstFolders})
    #add_isis_module_test(${f})
  endforeach()  
  
endfunction(add_isis_module)







