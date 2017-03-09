# Script to run a unit test and compare the result to a truth file.
# - This replaces the ISIS UnitTester script.

# Set up the test something like this:

# TODO

# Needed for ISIS to find its Preferences files where they
# are buried in the src directory.
# - In addition, library files and .plugin files need to be found
#   in ISISROOT/lib.
set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
set(ENV{ISIS3DATA} "${DATA_ROOT}")
message("ISISROOT = $ENV{ISISROOT}")
message("ISIS3DATA = $ENV{ISIS3DATA}")

# Set up temp file for program output
#get_filename_component(TEST_NAME ${TEST_PROG} NAME_WE)
set(outputFile "${TEST_PROG}.output")
message("outputFile = ${outputFile}")
file(REMOVE ${outputFile}) # Make sure no old file exists

message("CMD = ${TEST_PROG} 1>${outputFile} 2>&1 || exit 4")

# The test programs need to be run from their source folders
#  so that they can find input data files.
get_filename_component(truthFolder ${TRUTH_FILE} DIRECTORY)
#get_filename_component(objectName ${truthFolder} NAME)

# Run the unit test executable and pipe the output to a text file.
execute_process(COMMAND ${TEST_PROG}
                WORKING_DIRECTORY ${truthFolder}
                OUTPUT_FILE ${outputFile}
                ERROR_FILE ${outputFile}
                OUTPUT_VARIABLE result
                RESULT_VARIABLE code)
if(result)
    message("Test failed: ${result}, ${code}")
endif()

# If an exclusion file is present, use it to filter out selected lines.
# - Do this by comparing filtered versions of the two files, then
#   running the diff on those two temporary files.
set(comp1 ${outputFile})
set(comp2 ${TRUTH_FILE})
set(exclusionPath ${truthFolder}/unitTest.exclude)
message("exclusionPath = ${exclusionPath}")
if(EXISTS ${exclusionPath})
  # This throws out all lines containing a word from the exclusion file.
  execute_process(COMMAND cat ${outputFile} | grep -v -f ${exclusionPath}
                  OUTPUT_FILE ${comp1})
  execute_process(COMMAND cat ${TRUTH_FILE} | grep -v -f ${exclusionPath}
                  OUTPUT_FILE ${comp2})
endif()

# Verify that the files are exactly the same
execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files
    ${comp1} ${comp2}
    RESULT_VARIABLE DIFFERENT)
if(DIFFERENT)
    message(FATAL_ERROR "Test failed - files differ")
    # On error the result file is left around to aid in debugging.
else()
  file(REMOVE ${outputFile}) # On success, clean out the result file.
endif()

if(EXISTS ${exclusionPath})
  # Clean up temporary files if we created them
  file(REMOVE ${comp1})
  file(REMOVE ${comp2})
endif()




