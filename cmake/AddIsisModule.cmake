#===============================================================================
#        Add a single folder in the src directory
#
#===============================================================================

# TODO: Split into multiple files


#----------------------------------------------------
function(add_isis_app folder libDependencies)

  # Folders: assets, tsts

  get_filename_component(appName ${folder}  NAME)
  message("Proccesing APP folder: ${folder}")

  # Find the source and header files
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  file(GLOB xmlFiles "${folder}/*.xml")
  
  # All the XML files need to be copied to the install directory
  copy_files_to_folder(${xmlFiles} "${CMAKE_INSTALL_PREFIX}/bin/xml")

  # Generate required QT files
  generate_moc_files(mocFiles ${folder})

  # Set up the executable 
  add_executable(${appName} ${headers} ${sources} ${mocFiles})
  set_target_properties(${appName} PROPERTIES LINKER_LANGUAGE CXX)

  # Handle individual apps that have additional library requirements
  set(finalLibDeps ${libDependencies})
  if((${appName} STREQUAL "amicacal") OR (${appName} STREQUAL "findfeatures"))
    set(finalLibDeps ${finalLibDeps} ${OPENCVLIB})
  elseif(${appName} STREQUAL "cnet2dem")
    set(finalLibDeps ${finalLibDeps} ${NNLIB})
  endif()
  #message("finalLibDeps = ${finalLibDeps}")

  target_link_libraries(${appName} ${finalLibDeps})
  install(TARGETS ${appName} DESTINATION bin)

 
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
macro(make_obj_unit_test moduleName testFile truthFile reqLibs pluginLibs)

  # Get file name without extension
  get_filename_component(filename ${truthFile} NAME_WE)

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
  #message("executableName = ${executableName}")

  # Create the executable and link it to the module library
  #message("link to ${moduleName}")
  add_executable( ${executableName} ${testFile}  )
  set(depLibs "${reqLibs};${matchedLibs}") # TODO: Check!
  #message("depLibs = ${depLibs}")
  target_link_libraries(${executableName} ${moduleName} ${depLibs}) # TODO: Check!
  #message( FATAL_ERROR "STOP." )

  # TODO: Make test build/installion optional!
  install(TARGETS ${executableName} DESTINATION tests)

  # Add this test to the unit test command
  add_unit_test_target(${executableName} ${truthFile})

endmacro()

#----------------------------------------------------
# Load information about a single obj folder
function(add_isis_obj folder reqLibs)

  # Includes the class, unit test app, and unit test truth result

  #message("Processing OBJ folder: ${folder}")

  # Look inside this folder for include files
  include_directories(${folder})

  # Find the source and header files
  # TODO: Verify only one truth file!
  file(GLOB headers "${folder}/*.h" "${folder}/*.hpp")
  file(GLOB sources "${folder}/*.c" "${folder}/*.cpp")
  file(GLOB truths  "${folder}/*.truth")
  file(GLOB plugins "${folder}/*.plugin")

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


  # Output assignments are locally first so we can check them at the local scope.
  set(thisSourceFiles ${headers} ${sources} ${protoFiles} ${uiFiles} ${mocFiles})
  set(thisTruthFiles  ${truths} )
  
  # TODO: Choose the truth file based on the OS!!!!
  # Verify that the number of tests and truths are equal!
  list(LENGTH thisTestFiles numTest)
  list(LENGTH thisTruthFiles numTruth)
  if(NOT (${numTest} EQUAL ${numTruth}) )
    #message("UNEQUAL TEST!!!!!!")
    #message("testFiles = ${thisTestFiles}")
    #message("truths = ${thisTruthFiles}")
    list(GET thisTruthFiles 0 thisTruthFiles )
    message("Selected truth file = ${thisTruthFiles}")
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

    message("Found plugins: ${plugins}")

    if(NOT (${numPlugins} EQUAL 1))
      message( FATAL_ERROR "Error: Multiple plugins found in folder!" )
    endif()

    get_filename_component(libName    ${folder}  NAME)
    get_filename_component(pluginName ${plugins} NAME)
    #message("Adding special library: ${libName}")
    #message("SOURCE FILES: ${thisSourceFiles}")

    add_library_wrapper(${libName} "${thisSourceFiles}" "${reqLibs}")

    # Append the plugin file to a single file in the install/lib folder
    set(pluginPath ${CMAKE_INSTALL_PREFIX}/lib/${pluginName})
    #message("Appending plugin to ${pluginPath}")
    cat(${plugins} ${pluginPath})

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

    message("Processing TOP FOLDER ${f}")

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
  if(${name} STREQUAL ${CORE_LIB_NAME})
    set(reqLibs ${ALLLIBS})
  else()
    set(reqLibs "${CORE_LIB_NAME};${ALLLIBS}")
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
  message("Plugin libs: ${pluginLibs}")

  #message("Found app folders: ${APP_FOLDERS}")
  #message("Found obj folders: ${OBJ_FOLDERS}")
  #message("Found test folders: ${TST_FOLDERS}")

  # Some modules don't generate a library
  list(LENGTH sourceFiles temp)
  if (NOT ${temp} EQUAL 0)
    add_library_wrapper(${name} "${sourceFiles}" "${reqLibs}")

    # Have the plugin libraries depend on the module library
    foreach(plug ${pluginLibs})
      target_link_libraries(${plug} ${name})
    endforeach()

    # For everything beyond the module library, require the module library.
    set(reqLibs "${reqLibs};${name}")
    message("reqLibs = ${reqLibs}")
    #message( FATAL_ERROR "STOP." )

    # Now that the library is added, add all the unit tests for it.
    list(LENGTH unitTestFiles temp)
    math(EXPR numTests "${temp} - 1")
    message("NUM_TESTS = ${numTests}")
    foreach(val RANGE ${numTests})
      list(GET unitTestFiles ${val} testFile )
      list(GET truthFiles    ${val} truthFile)
      make_obj_unit_test(${name} ${testFile} ${truthFile} "${reqLibs}" "${pluginLibs}")
    endforeach()

  endif()
 
  # Process the apps
  foreach(f ${appFolders})
    # Apps always require the core library
    add_isis_app(${f} "${reqLibs}")
  endforeach()
  
  # Process the tests
  foreach(f ${tstFolders})
    #add_isis_module_test(${f})
  endforeach()  
  
endfunction(add_isis_module)







