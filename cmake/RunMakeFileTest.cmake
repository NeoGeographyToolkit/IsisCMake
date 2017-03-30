#============================================================================
# Script to read in a MakeFile based test and run it without relying on any
# of the old Makefile infrastructure.
#============================================================================

cmake_minimum_required(VERSION 3.3)
#message("source dir = ${CMAKE_SOURCE_DIR}")
list(APPEND CMAKE_MODULE_PATH "$ENV{ISISROOT}/cmake")
list(APPEND CMAKE_PREFIX_PATH "$ENV{ISISROOT}/cmake")
include(Utilities)

# Function to run the test and check the results
function(run_app_makefile_test makefile inputFolder outputFolder truthFolder binFolder)

  # Build the test name
  get_filename_component(sourceFolder ${makefile}     DIRECTORY)
  get_filename_component(testName     ${sourceFolder} NAME)
  get_filename_component(folder       ${sourceFolder} DIRECTORY)
  get_filename_component(folder       ${folder}       DIRECTORY)
  get_filename_component(appName      ${folder}       NAME)
  set(appName ${appName}_${testName})

  # Check if there are copies of the input/truth folders in the source folder,
  #  if so use those instead of the original location.
  if(EXISTS ${sourceFolder}/input)
    set(inputFolder ${sourceFolder}/input)
  endif()
  if(EXISTS ${sourceFolder}/truth)
    set(truthFolder ${sourceFolder}/truth)
  endif()

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
  compare_folders(${truthFolder} ${outputFolder} ${makefile})
  
endfunction()




# Set result to the tolerance string to be passed to a cubediff call for a given file.
function(find_tolerance_value makefile filename toleranceString)
  
   # Read in the MakeFile
  if(NOT EXISTS ${makefile})
    message(FATAL_ERROR "App test MakeFile ${makefile} was not found!")
  endif()
  file(READ ${makefile} makefileContents)
  
  # Split out the command section
  string(FIND "${makefileContents}" "commands:" commandLoc) 
  string(SUBSTRING "${makefileContents}" 0 ${commandLoc} definitions)

  # Parse out the name assignments
  set(regexWord "[A-Za-z0-9 \\.-]+")
  string(REGEX MATCHALL "${regexWord}=${regexWord}"
       parsedDefinitions "${definitions}") 

  get_filename_component(filename ${filename} NAME)

  # Find/Replace all the word name assignments in the command.
  foreach(pair ${parsedDefinitions})
    string(REGEX MATCHALL "[^= ]+" parts "${pair}")
    list(GET parts 0 name)
    list(GET parts 1 value)
    #message("name = ${name}")
    #message("value = ${value}")

    string(FIND "${name}" "TOLERANCE" tolPos)
    string(FIND "${name}" ${filename} namePos)
    if((NOT ${tolPos} EQUAL -1) AND (NOT ${namePos} EQUAL -1))
      # Extract the file name this value applies to
      string(REPLACE ".TOLERANCE" "" fileName ${name})
      
      # Generate the tolerance argument
      set(toleranceString "tolerance=${value}" PARENT_SCOPE)
      return()
    endif()
  endforeach()
  
  # Default when the tolerance is not found
  set(toleranceString "" PARENT_SCOPE)
endfunction()


# Compare a .CUB file from a test result with the truth file
function(compare_test_result_cub testResult truthFile makefile result)

  # Look up all the TOLERANCE values from the makefile
  find_tolerance_value(${makefile} ${testResult} toleranceString)

  # Execute the cubediff script
  set(cmd ${CMAKE_BINARY_DIR}/cubediff ${TSTARGS} from=${truthFile} from2=${testResult} to=${OUTPUT_DIR}/compare.txt)
  set(cmd ${cmd} ${toleranceString})
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code 
                  OUTPUT_FILE ${OUTPUT_DIR}/cubediffOut.txt 
                  ERROR_FILE ${OUTPUT_DIR}/cubediffError.txt)

  message("cmd = ${cmd}")
  message("code = ${code}")

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    file_contains(${OUTPUT_DIR}/compare.txt "Compare = Identical" isIdentical) # TODO: Use getkey app
    if(${isIdentical})
      set(result OFF PARENT_SCOPE)
    endif()
  endif()
  # Cleanup temp files
  file(REMOVE ${OUTPUT_DIR}/compare.txt ${OUTPUT_DIR}/cubediffOut.txt ${OUTPUT_DIR}/cubediffError.txt)
endfunction()

# Compare a .TXT file from a test result with the truth file
function(compare_test_result_txt testResult truthFile result)

  set(cmd diff ${truthFile} ${testResult})
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()
endfunction()

# Compare a .CSV file from a test result with the truth file
function(compare_test_result_csv testResult truthFile result)

  set(cmd $ENV{ISISROOT}/scripts/csvdiff.py ${truthFile} ${testResult})

  # This is an optional file that sets parameters for the csvdiff command
  get_filename_component(name ${testResult} NAME)
  set(diffValsFile ${INPUT_DIR}/${name}.DIFF)
  if(EXISTS ${diffValsFile})
    set(cmd ${cmd} ${diffValsFile})
  endif()
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    set(result OFF PARENT_SCOPE)
  endif()
endfunction()

# Compare a .PVL file from a test result with the truth file
function(compare_test_result_pvl testResult truthFile result)

  set(cmd ${CMAKE_BINARY_DIR}/pvldiff ${TSTARGS} from=${truthFile} from2=${testResult} to=${OUTPUT_DIR}/compare.txt)
  # This is an optional file that sets parameters for the pvldiff command
  get_filename_component(name ${testResult} NAME)
  set(diffValsFile ${INPUT_DIR}/${name}.DIFF)
  if(EXISTS ${diffValsFile})
    set(cmd ${cmd} diff=${diffValsFile})
  endif()
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code 
                  OUTPUT_FILE ${OUTPUT_DIR}/pvldiffOut.txt
                  ERROR_FILE ${OUTPUT_DIR}/pvldiffError.txt)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    # A zero error code does not mean success, we still need to do a check.
    file_contains(${OUTPUT_DIR}/compare.txt "Compare = Identical" isIdentical) # TODO: Use getkey app
    if(${isIdentical})
      set(result OFF PARENT_SCOPE)
    endif()
  endif()
endfunction()

# Compare a .NET file from a test result with the truth file
function(compare_test_result_net testResult truthFile result)

  set(cmd ${CMAKE_BINARY_DIR}/cnetdiff ${TSTARGS} from=${truthFile} from2=${testResult} to=${OUTPUT_DIR}/compare.txt)

  # This is an optional file that sets parameters for the pvldiff command
  get_filename_component(name ${testResult} NAME)
  set(diffValsFile ${INPUT_DIR}/${name}.DIFF)
  if(EXISTS ${diffValsFile})
    set(cmd ${cmd} diff=${diffValsFile})
  endif()
  execute_process(COMMAND ${cmd} RESULT_VARIABLE code ERROR_FILE ${OUTPUT_DIR}/cnetdiffError.txt)

  set(result ON PARENT_SCOPE)
  if("${code}" STREQUAL "0")
    # A zero error code does not mean success, we still need to do a check.
    file_contains(${OUTPUT_DIR}/compare.txt "Compare = Identical" isIdentical) # TODO: Use getkey app
    if(${isIdentical})
      set(result OFF PARENT_SCOPE)
   endif()
  endif()
endfunction()

# Compare a test output to the corresponding truth file.
# - Each type of file has a different comparison method.
function(compare_test_result_file testResult truthFile makefile result)

  set(TSTARGS "-preference=$ENV{ISISROOT}/src/base/objs/Preference/TestPreferences")

  # Redirect to the type specific comparison via the extension
  string(FIND ${truthFile} "." pos REVERSE)
  string(SUBSTRING ${truthFile} ${pos} -1 ext)

  if (${ext} STREQUAL ".cub")
    compare_test_result_cub(${testResult} ${truthFile} ${makefile} result)
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

  # Check the result
  if(${result} STREQUAL ON)
    message("Files ${testResult} and ${truthFile} are different!")
    # TODO: Print error log!
  else() # OFF
    message("Files ${testResult} and ${truthFile} match!") # TODO: Remove
  endif()
  set(result ${result} PARENT_SCOPE)

endfunction()

# Function to check each test result in the output folder
function(compare_folders truthFolder outputFolder makefile)

  # Get a list of all files in the truth folder
  file(GLOB truthFiles "${truthFolder}/*")
  
  # Compare the contents of each truth file to the associated output file
  set(failed "OFF")
  foreach(f ${truthFiles})

    # Get the expected file
    get_filename_component(name ${f} NAME)
    set(testFile ${outputFolder}/${name})
    if(NOT EXISTS ${testFile})
      message(WARNING "Output file does not exist: ${testFile}")
      set(failed "ON")
      continue()
    endif()

    # Compare the file
    compare_test_result_file(${testFile} ${truthFolder}/${name} ${makefile} result)
    if(${result})
      set(failed "ON")
    endif()
  endforeach()
 
  # If any file failed, the test is a failure.
  if(${failed})
    message(FATAL_ERROR "Test failed.")
  endif()

endfunction()


#===================================================================================
# This is the main script that gets run during the test.
# - Just redirect to the main function call.

# TODO: Check these work from other build folders
# Needed for IsisPreferences and other test data to be found
set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
set(ENV{ISIS3DATA} "${DATA_ROOT}")

message("source dir = ${CMAKE_SOURCE_DIR}")

run_app_makefile_test(${MAKEFILE} ${INPUT_DIR} ${OUTPUT_DIR} ${TRUTH_DIR} ${BIN_DIR})


