# Script to run a unit test and compare the result to a truth file.
# - This replaces the ISIS UnitTester script.

# Set up the test something like this:

# TODO

# Set up temp file for program output
set(tempFile "unitTest.output")
file(REMOVE ${tempFile}) # Make sure no old file

# Run the unit test executable and pipe the output to a text file.
execute_process(COMMAND "${TEST_PROG} 1>${tempFile} 2>&1"
                RESULT_VARIABLE HAD_ERROR)
if(HAD_ERROR)
    message(FATAL_ERROR "Test failed")
endif()

# Verify that the files are exactly the same
execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files
    ${tempFile} ${TRUTH_FILE}
    RESULT_VARIABLE DIFFERENT)
if(DIFFERENT)
    message(FATAL_ERROR "Test failed - files differ")
endif()


