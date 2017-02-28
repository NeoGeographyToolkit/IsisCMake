
# Tools to help set up the various ISIS tests.  
# There are three test categories:
# - Unit tests
# - App tests
# - Category tests

# Set up the build target for each test type
add_custom_target(run_unit_tests)
add_custom_target(run_app_tests)
add_custom_target(run_category_tests)

# Set up macros for adding individual tests to the test commands
# TODO: Check this! 
macro(add_unit_test_target testFile truthFile)
  #add_custom_target(${test_target}_runtest
  #                  COMMAND ${test_target} #cmake 2.6 required
  #                  DEPENDS ${test_target}
  #                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
  #add_dependencies(run_unit_tests ${test_target}_runtest)
  
  set(thisFolder "${PROJECT_SOURCE_DIR}/cmake")
  #set(testInstallFolder ${CMAKE_INSTALL_PREFIX}/tests) # TODO: Change dir?
  #set(fullTestPath "${testInstallFolder}/${testFile}")
  set(fullTestPath "${CMAKE_BINARY_DIR}/src/${testFile}")

  # Redirect the test and truth file through a CMake script to run the
  #  test and check the outputs
  set(testName ${testFile}) # TODO: Make a new name?
  add_test(NAME ${testName} 
           COMMAND ${CMAKE_COMMAND}
           -DTEST_PROG=${fullTestPath}
           -DTRUTH_FILE=${truthFile}
           -P ${thisFolder}/RunUnitTest.cmake)

  #set_property(TEST ${testName} PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src")


endmacro()


# TODO: Macros for the other two test types
