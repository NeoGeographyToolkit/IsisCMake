
# Tools to help set up the various ISIS tests.  
# There are three test categories:
# - Unit tests
# - App tests
# - Category tests

# Set up the build target for each test type
add_custom_target(run_unit_tests)
add_custom_target(run_app_tests)
add_custom_target(run_category_tests)

# Set up a unit test
macro(add_unit_test_target testFile truthFile)
  
  set(thisFolder "${PROJECT_SOURCE_DIR}/cmake")
  set(fullTestPath "${CMAKE_BINARY_DIR}/src/${testFile}") # The binary that the script will execute

  # Redirect the test and truth file through a CMake script to run the
  #  test and check the outputs
  set(testName ${testFile})
  add_test(NAME ${testName} 
           COMMAND ${CMAKE_COMMAND}
           -DTEST_PROG=${fullTestPath}
           -DTRUTH_FILE=${truthFile}
           -DDATA_ROOT=$ENV{ISIS3DATA}
           -P ${thisFolder}/RunUnitTest.cmake)
endmacro()


# Set up an app test
macro(add_app_test_target testName makeFile inputDir outputDir truthDir)
  #add_custom_target(${test_target}_runtest
  #                  COMMAND ${test_target} #cmake 2.6 required
  #                  DEPENDS ${test_target}
  #                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
  #add_dependencies(run_unit_tests ${test_target}_runtest)
  
  set(thisFolder "${PROJECT_SOURCE_DIR}/cmake")

  # TODO: Set things up so the tests are run by separate commands!!!!

  # Set up a cmake script which will execute the command in the makefile
  #  and then check the results against the truth folder.
  add_test(NAME ${testName} 
           COMMAND ${CMAKE_COMMAND}
           -DMAKEFILE=${makeFile}
           -DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
           -DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
           -DDATA_ROOT=$ENV{ISIS3DATA}
           -DINPUT_DIR=${inputDir}
           -DOUTPUT_DIR=${outputDir}
           -DTRUTH_DIR=${truthDir}
           -DBIN_DIR=${CMAKE_BINARY_DIR}/src
           -P ${thisFolder}/RunMakeFileTest.cmake)

endmacro()
