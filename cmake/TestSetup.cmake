
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
  
  # Redirect the test and truth file through a CMake script to run the
  #  test and check the outputs
  add_test(NAME ${testFile} # TODO: Make a new name?
           COMMAND ${CMAKE_COMMAND}
           -DTEST_PROG=${testFile}
           -DTRUTH_FILE=${truthFile}
           -P ${CMAKE_CURRENT_SOURCE_DIR}/RunUnitTest.cmake)
  
endmacro()


# TODO: Macros for the other two test types
