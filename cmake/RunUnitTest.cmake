# Script to run a unit test and compare the result to a truth file.
# - This replaces the ISIS UnitTester script.

# Set up the test something like this:

# TODO

# Set up temp file for program output
#get_filename_component(TEST_NAME ${TEST_PROG} NAME_WE)
set(tempFile "${TEST_PROG}.output")
#message("tempFile = ${tempFile}")
file(REMOVE ${tempFile}) # Make sure no old file exists

#message("CMD = ${TEST_PROG} 1>${tempFile} 2>&1")

# Run the unit test executable and pipe the output to a text file.
execute_process(${TEST_PROG} 1>${tempFile} 2>&1
                OUTPUT_VARIABLE result
                RETURN_VALUE code)
if(result)
    message("Test failed: ${result}, ${code}")
endif()

# Verify that the files are exactly the same
execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files
    ${tempFile} ${TRUTH_FILE}
    RESULT_VARIABLE DIFFERENT)
if(DIFFERENT)
    message(FATAL_ERROR "Test failed - files differ")
    # On error the result file is left around to aid in debugging.
else()
  file(REMOVE ${tempFile}) # On success, clean out the result file.
endif()


