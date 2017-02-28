# Script to run a unit test and compare the result to a truth file.
# - This replaces the ISIS UnitTester script.

# Set up the test something like this:

# TODO

# Needed for ISIS to find its Preferences files where they
# are buried in the src directory.
# - In addition, library files and .plugin files need to be found
#   in ISISROOT/lib.
set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")

message("ENV{ISISROOT} = $ENV{ISISROOT}")

# Set up temp file for program output
#get_filename_component(TEST_NAME ${TEST_PROG} NAME_WE)
set(tempFile "${TEST_PROG}.output")
message("tempFile = ${tempFile}")
file(REMOVE ${tempFile}) # Make sure no old file exists

message("CMD = ${TEST_PROG} > ${tempFile} 2>&1")

# The test programs need to be run from their source folders
#  so that they can find input data files.
get_filename_component(truthFolder ${TRUTH_FILE} DIRECTORY)

# Run the unit test executable and pipe the output to a text file.
execute_process(COMMAND ${TEST_PROG}
                WORKING_DIRECTORY ${truthFolder}
                OUTPUT_FILE ${tempFile}
                ERROR_FILE ${tempFile}
                OUTPUT_VARIABLE result
                RESULT_VARIABLE code)
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


