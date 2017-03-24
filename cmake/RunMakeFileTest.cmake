# The purpose of this script is to read in one of the existing application 
# tests defined in a MakeFile and then run the test without relying on any
# of the old Makefile infrastructure.
# - To avoid using this script, all of the old MakeFile tests would need to
#   be converted into some other format.

# TODO: Move some code out of this file?


# Parse an app folder Makefile to generate and run a 
# command line string for a test.
function(run_app_makefile_test makefile inputFolder outputFolder truthFolder binFolder)

  #message("truth folder == ${truthFolder}")
  get_filename_component(folder ${makeFile} DIRECTORY)
  get_filename_component(appName ${folder} NAME)
  message("appName = ${appName}")


  # Read in the MakeFile
  if(NOT EXISTS ${makefile})
    message(FATAL_ERROR "App test MakeFile ${makefile} was not found!")
  endif()
  file(READ ${makefile} makefileContents)
  
  # Split out the command section
  string(FIND "${makefileContents}" "commands:" commandLoc)
  #message("commandLoc = ${commandLoc}")
  
  string(SUBSTRING "${makefileContents}" 0 ${commandLoc} definitions)
  math(EXPR commandLoc "${commandLoc}+10")
  string(SUBSTRING "${makefileContents}" ${commandLoc} -1 command)
  
  message("definitions = ${definitions}")
  message("command = ${command}")
  set(modCommand "${command}")

  #message("modcommand = ${modCommand}")

  # Parse out the name assignments
  set(regexWord "[A-Za-z0-9 \\.-]+")
  string(REGEX MATCHALL "${regexWord}=${regexWord}"
       parsedDefinitions "${definitions}")
  message("parsedDefinitions: ${parsedDefinitions}")
  
  # Add name assignments not specified in the file
  list(APPEND parsedDefinitions "INPUT=${inputFolder}" "OUTPUT=${outputFolder}" "RM=rm" "CP=cp" "LS=ls" "MV=mv" "SED=sed")
  
  # TODO: Look out for weird tolerance variables.
  #TSTARGS = -preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences
  
  # Find/Replace all the word name assignments in the command.
  foreach(pair ${parsedDefinitions})
    string(REGEX MATCHALL "[^= ]+" parts "${pair}")
    list(GET parts 0 name)
    list(GET parts 1 value)

    #message("parts: ${parts}")
    #message("name = ${name}")
    #message("value = ${value}")

    # Handle specified tolerance parameters
    # - These are just arguments specified in a roundabout method
    
    string(FIND "${name}" "TOLERANCE" tolPos)
    if(${tolPos} EQUAL -1)
      # Non-tolerance parameter
      string(REPLACE "$(${name})" ${value} modCommand "${modCommand}")
    else()
      # Extract the file name this value applies to
      string(REPLACE ".TOLERANCE" "" fileName ${name})
      #message("filename = ${fileName}")
      # Insert the tolerance argument
      string(REPLACE ${fileName} "${fileName} tolerance=${value}" modCommand "${modCommand}")
    endif()
    
  endforeach()

  message("modCommand = ${modCommand}")
  #message("binFolder = ${binFolder}")

  # TODO: How much is needed?
  # Do some string cleanup
  #string(STRIP "${modCommand}" modCommand)                      # Clear leading whitespace
  #string(REPLACE "\\" " "  modCommand "${modCommand}")          # Remove line continuation marks.
  #string(REPLACE "\n" ""  modCommand "${modCommand}")           # Remove end-of-line characters.
  string(REPLACE ">& /dev/null" ""  modCommand "${modCommand}") # Allow output to the log file.
  string(REPLACE "> /dev/null" ""  modCommand "${modCommand}") 
  #string(REGEX REPLACE "[ \t]+" " " modCommand "${modCommand}") # Replace whitespace with " ".
  message("modCommand = ${modCommand}")

  # TODO: Make path unique!

  # Copy the finished command string to a shell file for execution
  set(scriptPath "${binFolder}/tempScript.sh")
  message("path = ${scriptPath}")
  execute_process(COMMAND rm -rf ${scriptPath})
  file(WRITE ${scriptPath}  "export PATH=${binFolder}:$PATH;\n") # Append the binary location to PATH
  file(APPEND ${scriptPath} "export ISISROOT=$ENV{ISISROOT};\n")
  file(APPEND ${scriptPath} "${modCommand}") 

  # Execute the scrip we just generated
  set(code "")
  set(logFile ${binFolder}/${appName}_log.txt)
  execute_process(COMMAND rm -rf ${outputFolder})
  execute_process(COMMAND rm -f ${logFile})
  execute_process(COMMAND mkdir -p ${outputFolder})
  execute_process(COMMAND chmod +x ${scriptPath})
  execute_process(COMMAND ${scriptPath}
                  WORKING_DIRECTORY ${outputFolder} 
                  OUTPUT_FILE ${logFile}
                  ERROR_FILE ${logFile}
                  OUTPUT_VARIABLE result
                  RESULT_VARIABLE code)

  if(result)
    message("App test failed: ${result}, ${code}")
  endif()

  
  # TODO: Handle TOLERANCE lines!
  
  message("Starting folder comparison...")
  compare_folders(${truthFolder} ${outputFolder})
 

endfunction()





function(run_app_makefile_test2 makefile inputFolder outputFolder truthFolder binFolder)

  get_filename_component(folder ${makefile} DIRECTORY)
  get_filename_component(testName ${folder} NAME)
  get_filename_component(folder ${folder} DIRECTORY)
  get_filename_component(folder ${folder} DIRECTORY)
  get_filename_component(appName ${folder} NAME)
  set(appName ${appName}_${testName})
  message("appName = ${appName}")

  # Read in the MakeFile
  if(NOT EXISTS ${makefile})
    message(FATAL_ERROR "App test MakeFile ${makefile} was not found!")
  endif()
  file(READ ${makefile} makefileContents)

  # Replace include line with short list of definitions
  set(newDefinitions "INPUT=${inputFolder}\nOUTPUT=${outputFolder}\nRM=rm -f\nCP=cp\nLS=ls\nMV=mv\nSED=sed\nTAIL=tail\nECHO=echo\nCAT=cat\nLS=ls")
  string(REPLACE "include $(ISISROOT)/make/isismake.tsts" "${newDefinitions}" newFileContents "${makefileContents}")

  string(REPLACE ">& /dev/null" ""  newFileContents "${newFileContents}") # Allow output to the log file.
  string(REPLACE "> /dev/null" ""  newFileContents "${newFileContents}")

  # TODO: Handle tolerance lines!  
  # TODO: Make path unique!

  # Copy the finished command string to a shell file for execution
  set(scriptPath "${binFolder}/newMakeFile")
  message("path = ${scriptPath}")
  file(WRITE ${scriptPath} "${newFileContents}") 

  set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
  set(ENV{ISIS3DATA} "${DATA_ROOT}")
  set(ENV{PATH} "${binFolder}:$ENV{PATH}")


  # Execute the scrip we just generated
  set(code "")
  set(logFile "${binFolder}/${appName}.log")
  message("logFile = ${logFile}")
  execute_process(COMMAND rm -rf ${outputFolder})
  execute_process(COMMAND rm -f ${logFile})
  execute_process(COMMAND mkdir -p ${outputFolder})
  #execute_process(COMMAND chmod +x ${scriptPath})
  execute_process(COMMAND make -f "${scriptPath}"
                  WORKING_DIRECTORY ${outputFolder} 
                  OUTPUT_FILE ${logFile}
                  ERROR_FILE ${logFile}
                  OUTPUT_VARIABLE result
                  RESULT_VARIABLE code)

  if(result)
    message("App test failed: ${result}, ${code}")
  endif()

  message("Starting folder comparison...")
  compare_folders(${truthFolder} ${outputFolder})
  
endfunction()






# Compare a .CUB file from a test result with the truth file
function(compare_test_result_cub testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
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

  # TODO: Common comparison tasks.

  # TODO: SHARE THIS!
  message("CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")
  set(TSTARGS "-preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences")

  # Redirect to the type specific comparison via the extension
  string(FIND ${truthFile} "." pos REVERSE)
  string(SUBSTRING ${truthFile} ${pos} -1 ext)
  message("Read extension: ${ext}")  

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
    message("comparing truth filename = ${f}")
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

#message("makefile = ${MAKEFILE}")
#message("input dir = ${INPUT_DIR}")
#message("output dir  = ${OUTPUT_DIR}")
#message("truth dir  = ${TRUTH_DIR}")
#message("bin dir  = ${BIN_DIR}")

# Needed for IsisPreferences and other test data to be found
set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}/../..")
set(ENV{ISIS3DATA} "${DATA_ROOT}")
message("IROOT = ${CMAKE_SOURCE_DIR}/../..")

run_app_makefile_test2(${MAKEFILE} ${INPUT_DIR} ${OUTPUT_DIR} ${TRUTH_DIR} ${BIN_DIR})


