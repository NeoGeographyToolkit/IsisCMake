#============================================================================
# Script to read in a MakeFile based test and run it without relying on any
# of the old Makefile infrastructure.
#============================================================================


# Function to run the test and check the results
function(run_app_makefile_test makefile inputFolder outputFolder truthFolder binFolder)

  # Build the test name
  get_filename_component(folder   ${makefile} DIRECTORY)
  get_filename_component(testName ${folder}   NAME)
  get_filename_component(folder   ${folder}   DIRECTORY)
  get_filename_component(folder   ${folder}   DIRECTORY)
  get_filename_component(appName  ${folder}   NAME)
  set(appName ${appName}_${testName})

  # Read in the MakeFile
  if(NOT EXISTS ${makefile})
    message(FATAL_ERROR "App test MakeFile ${makefile} was not found!")
  endif()
  file(READ ${makefile} makefileContents)

  # Replace include line with a short list of definitions
  set(newDefinitions "INPUT=${inputFolder}\nOUTPUT=${outputFolder}\nRM=rm -f\nCP=cp\nLS=ls\nMV=mv\nSED=sed\nTAIL=tail\nECHO=echo\nCAT=cat\nLS=ls")
  string(REPLACE "include $(ISISROOT)/make/isismake.tsts" "${newDefinitions}" newFileContents "${makefileContents}")

  # Remove the output suppressant so that the log contains more information
  string(REPLACE ">& /dev/null" ""  newFileContents "${newFileContents}") 
  string(REPLACE "> /dev/null" ""  newFileContents "${newFileContents}")

  # TODO: Handle tolerance lines!  
  # TODO: Make path unique!

  # Copy the finished command string to a shell file for execution
  set(scriptPath "${binFolder}/newMakeFile")
  file(WRITE ${scriptPath} "${newFileContents}") 

  # Set required environment variables
  set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
  set(ENV{ISIS3DATA} "${DATA_ROOT}")
  set(ENV{PATH} "${binFolder}:$ENV{PATH}")

  # Select the log file
  set(logFile "${binFolder}/${appName}.output")
  message("logFile = ${logFile}")

  # Execute the Makefile we just generated
  set(code "")
  execute_process(COMMAND rm -rf ${outputFolder})
  execute_process(COMMAND rm -f ${logFile})
  execute_process(COMMAND mkdir -p ${outputFolder})
  if(NOT EXISTS ${outputFolder})
    message(FATAL_ERROR "Failed to create output folder: ${outputFolder}")
  endif()
  execute_process(COMMAND make -f "${scriptPath}"
                  WORKING_DIRECTORY ${outputFolder} 
                  OUTPUT_FILE ${logFile}
                  ERROR_FILE ${logFile}
                  OUTPUT_VARIABLE result
                  RESULT_VARIABLE code)
  if(result)
    message("Makefile test failed: ${result}, ${code}")
  endif()

  # Now verify the results
  compare_folders(${truthFolder} ${outputFolder})
  
endfunction()



# Compare a .CUB file from a test result with the truth file
function(compare_test_result_cub testResult truthFile result)

  # Execute the cubediff script
  set(cmd "${CMAKE_BINARY_DIR}/src/cubediff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt 1>>/dev/null 2>cubediffError.txt")
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  # TODO: CHECK TOLERANCES!
  message("code = ${code}")
  # TODO: More detailed error reporting.
  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()
endfunction()

# Compare a .TXT file from a test result with the truth file
function(compare_test_result_txt testResult truthFile result)

  set(cmd "diff ${truthFile} ${testResult} > /dev/null")
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()
endfunction()

# Compare a .CSV file from a test result with the truth file
function(compare_test_result_csv testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_SOURCE_DIR}/scripts/csvdiff.py ${truthFile} ${testResult} ${tempFile} >& /dev/null")
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()
endfunction()

# Compare a .PVL file from a test result with the truth file
function(compare_test_result_pvl testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/pvldiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>pvldiffError.txt")
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  # TODO: More detailed error reporting.
  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    # A zero error code does not mean success, we still need to do a check.
    set(cmd "${CMAKE_BINARY_DIR}/src/getkey from=compare.txt grp=Results keyword=Compare | tr '[:upper:]' '[:lower:]'")
    execute_process(COMMAD ${cmd} RESULT_VARIABLE code)

    if("${code}" STREQUAL "identical") # This code means a successful match
      set(result OFF PARENT_SCOPE)
    endif()
  endif()
endfunction()

# Compare a .NET file from a test result with the truth file
function(compare_test_result_net testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/cnetdiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>cnetdiffError.txt")
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  # TODO: More detailed error reporting.
  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()

endfunction()

# Compare a test output to the corresponding truth file.
# - Each type of file has a different comparison method.
function(compare_test_result_file testResult truthFile result)

  # TODO: SHARE THIS!
  message("CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")
  set(TSTARGS "-preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences")

  # Redirect to the type specific comparison via the extension
  string(FIND ${truthFile} "." pos REVERSE)
  string(SUBSTRING ${truthFile} ${pos} -1 ext)

  if (${ext} STREQUAL ".cub")
    compare_test_result_cub(${testResult} ${truthFile} result)
  elseif (${ext} STREQUAL ".txt")
    compare_test_result_txt(${testResult} ${truthFile} result)
  elseif (${ext} STREQUAL ".csv")
    compare_test_result_csv(${testResult} ${truthFile} result)
  elseif (${ext} STREQUAL ".pvl")
    compare_test_result_pvl(${testResult} ${truthFile} result)
  elseif (${ext} STREQUAL ".net")
    compare_test_result_net(${testResult} ${truthFile} result)
  else()
    # TODO: Explicitly check the binary extension list: jpg tif bin fits raw bmp png bc img imq
    compare_test_result_txt(${testResult} ${truthFile} result)

#    message(FATAL_ERROR "No rule to check test results of type ${ext}")
  endif()

  message("result = ${result}")
  if(${result} STREQUAL ON)
    message("Files ${testResult} and ${truthFile} are different!")
    # TODO: Print error log!
  else()
    message("Files ${testResult} and ${truthFile} match!") # TODO: Remove
  endif()

endfunction()

# Function to check each test result in the output folder
function(compare_folders truthFolder outputFolder)

  # Get a list of all files in the truth folder
  file(GLOB truthFiles "${truthFolder}/*")
  
  # Compare the contents of each truth file to the associated output file
  foreach(f ${truthFiles})
    get_filename_component(name ${f} NAME)
    set(testFile ${outputFolder}/${name})
    if(NOT EXISTS ${testFile})
      message(FATAL_ERROR "Output file does not exist: ${testFile}")
    endif()
    compare_test_result_file(${testFile} ${truthFolder}/${name} result)
  endforeach() 

endfunction()


#===================================================================================
# This is the main script that gets run during the test.
# - Just redirect to the main function call.

# TODO: Check these work from other build folders
# Needed for IsisPreferences and other test data to be found
set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
set(ENV{ISIS3DATA} "${DATA_ROOT}")

run_app_makefile_test(${MAKEFILE} ${INPUT_DIR} ${OUTPUT_DIR} ${TRUTH_DIR} ${BIN_DIR})


