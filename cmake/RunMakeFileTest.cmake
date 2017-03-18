# The purpose of this script is to read in one of the existing application 
# tests defined in a MakeFile and then run the test without relying on any
# of the old Makefile infrastructure.
# - To avoid using this script, all of the old MakeFile tests would need to
#   be converted into some other format.

# Sample MakeFile contents:
#APPNAME = lronac2isis
#FILE=nacl00015d79
#
#include $(ISISROOT)/make/isismake.tsts
#
#commands:
#	$(APPNAME) from=$(INPUT)/$(FILE).img \
#	  to=$(OUTPUT)/$(FILE).cub > /dev/null;
#	crop from=$(OUTPUT)/$(FILE).cub nlines=5 \
#	  to=$(OUTPUT)/$(FILE).small.cub > /dev/null;
#	catlab from=$(OUTPUT)/$(FILE).small.cub \
#	  to=$(OUTPUT)/$(FILE).small.pvl > /dev/null;
#	$(RM) $(OUTPUT)/$(FILE).cub;


# TODO: Move some code out of this file?


# Parse an app folder Makefile to generate and run a 
# command line string for a test.
function(run_app_makefile_test makefile inputFolder outputFolder truthFolder binFolder)

  #message("truth folder == ${truthFolder}")

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
  list(APPEND parsedDefinitions "INPUT=${inputFolder}" "OUTPUT=${outputFolder}" "RM=rm" "CP=cp" "LS=ls" "MV=mv")
  
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

  # Do some string cleanup
  string(STRIP "${modCommand}" modCommand)                      # Clear leading whitespace
  string(REPLACE "\\" " "  modCommand "${modCommand}")          # Remove line continuation marks.
  string(REPLACE "\n" ""  modCommand "${modCommand}")           # Remove end-of-line characters.
  string(REPLACE " > /dev/null" ""  modCommand "${modCommand}") # Remove output target.
  string(REGEX REPLACE "[ \t]+" " " modCommand "${modCommand}") # Replace whitespace with " ".
  message("modCommand = ${modCommand}")

  # Break up the string into separate command lines
  string(REGEX MATCHALL [^;]+ lines "${modCommand}")
  message("lines = ${lines}")

  # Set up for running commands
  set(code "")
  set(logFile ${outputFolder}/log.txt)
  execute_process(COMMAND mkdir -p ${outputFolder})

  # Run the command lines one at a time
  foreach(line ${lines})
    message("LINE == ${line}")

    # Split up tool and args part of the string (CMake needs this)
    string(STRIP ${line} line)
    string(FIND "${line}" " " pos)
    string(SUBSTRING "${line}" 0 ${pos} toolPart)
    string(SUBSTRING "${line}" ${pos} -1 argsPart)
    string(STRIP ${toolPart} toolPart) # Clear leading/trailing whitespace
    string(STRIP "${argsPart}" argsPart)
    string(REGEX REPLACE " " ";" argsPart "${argsPart}")
    message("toolPart = ${toolPart}")
    message("argsPart = ${argsPart}")

    # Actually run the command line
    execute_process(COMMAND ${binFolder}/${toolPart} ${argsPart}
#                    WORKING_DIRECTORY ${binFolder}
                    OUTPUT_FILE ${logFile}
                    ERROR_FILE ${logFile}
                    OUTPUT_VARIABLE result
                    RESULT_VARIABLE code)
    if(result)
      message("App test failed: ${result}, ${code}")
    endif()
  endforeach()
  
  # TODO: Handle TOLERANCE lines!
  
  message("Starting folder comparison...")
  compare_folders(${truthFolder} ${outputFolder})
  
  
  #message(FATAL_ERROR "STOP EARLY")



# Compare the files


endfunction()

# Compare a .CUB file from a test result with the truth file
function(compare_test_result_cub testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/cubediff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt 1>>/dev/null 2>cubediffError.txt")
  execute_process(COMMAND ${cmd})

  set(result ON PARENT_SCOPE)
endfunction()

# Compare a .TXT file from a test result with the truth file
function(compare_test_result_txt testResult truthFile result)

  set(cmd "diff ${truthFile} ${testResult} > /dev/null")
  execute_process(COMMAND ${cmd})

  set(result ON PARENT_SCOPE)
endfunction()

# Compare a .CSV file from a test result with the truth file
function(compare_test_result_csv testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_SOURCE_DIR}/scripts/csvdiff.py ${truthFile} ${testResult} ${tempFile} >& /dev/null")
  execute_process(COMMAND ${cmd})

  set(result ON PARENT_SCOPE)
endfunction()

# Compare a .PVL file from a test result with the truth file
function(compare_test_result_pvl testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/pvldiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>pvldiffError.txt")
  execute_process(COMMAND ${cmd})

  set(result ON PARENT_SCOPE)
endfunction()

# Compare a .NET file from a test result with the truth file
function(compare_test_result_net testResult truthFile result)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/cnetdiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>cnetdiffError.txt")
  execute_process(COMMAND ${cmd})

  set(result ON PARENT_SCOPE)
endfunction()

# Compare a test output to the corresponding truth file.
# - Each type of file has a different comparison method.
function(compare_test_result_file testResult truthFile result)

  # TODO: Common comparison tasks.

  # TODO: SHARE THIS!
  message("CMAKE_SOURCE_DIR = ${CMAKE_SOURCE_DIR}")
  set(TSTARGS "-preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences")

  # Redirect to the type specific  comparison
  get_filename_component(ext ${truthFile} EXT)
  
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
    # TODO: Use DIFF here?
    message(FATAL_ERROR "No rule to check test results of type ${ext}")
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

run_app_makefile_test(${MAKEFILE} ${INPUT_DIR} ${OUTPUT_DIR} ${TRUTH_DIR} ${BIN_DIR})


