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


# Parse an app folder Makefile to generate and run a 
# command line string for a test.
function(run_app_makefile_test makefile)

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
  
  #message("definitions = ${definitions}")
  #message("command = ${command}")

  set(modCommand ${command})

  # Parse out the name assignments
  set(regexWord "[A-Za-z0-9 ]+")
  string(REGEX MATCHALL "${regexWord}=${regexWord}"
       parsedDefinitions "${definitions}")
  message("parsedDefinitions: ${parsedDefinitions}")
  
  # Add name assignments not specified in the file
  # TODO: Set these properly!
  list(APPEND parsedDefinitions "INPUT=input" "OUTPUT=output" "RM=rm")
  
  # TODO: Look out for weird tolerance variables.
  #TSTARGS = -preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences
  
  # Find/Replace all the word name assignments in the command.
  foreach(pair ${parsedDefinitions})
    string(REGEX MATCHALL "[^= ]+" parts "${pair}")
    list(GET parts 0 name)
    list(GET parts 1 value)
    #message("parts: ${parts}")
    #message("name = $(${name})")
    #message("value = ${value}")
    string(REPLACE "$(${name})" ${value} modCommand ${modCommand})
  endforeach()
 
  message("modCommand = ${modCommand}")

  # TODO: Execute the command, then handle the results!
  
  message(FATAL_ERROR "STOP EARLY")

endfunction()

# Compare a .CUB file from a test result with the truth file
function(compare_test_result_cub testResult truthFile)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/cubediff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt 1>>/dev/null 2>cubediffError.txt")
  execute_process(COMMAND ${cmd})

endfunction()

# Compare a .TXT file from a test result with the truth file
function(compare_test_result_txt testResult truthFile)

  set(cmd "/usr/bin/diff ${truthFile} ${testResult} > /dev/null")
  execute_process(COMMAND ${cmd})

endfunction()

# Compare a .CSV file from a test result with the truth file
function(compare_test_result_csv testResult truthFile)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_SOURCE_DIR}/scripts/csvdiff.py ${truthFile} ${testResult} ${tempFile} >& /dev/null")
  execute_process(COMMAND ${cmd})

endfunction()

# Compare a .PVL file from a test result with the truth file
function(compare_test_result_pvl testResult truthFile)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/pvldiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>pvldiffError.txt")
  execute_process(COMMAND ${cmd})

endfunction()

# Compare a .NET file from a test result with the truth file
function(compare_test_result_net testResult truthFile)

  set(tempFile ${testResult}.DIFF)
  set(cmd "${CMAKE_BINARY_DIR}/src/cnetdiff ${TSTARGS} from=${truthFile} from2=${testResult} to=compare.txt diff=${tempFile} 1>>/dev/null 2>cnetdiffError.txt")
  execute_process(COMMAND ${cmd})

endfunction()

# Compare a test output to the corresponding truth file.
# - Each type of file has a different comparison method.
function(compare_test_result_file testResult truthFile)

  # TODO: Common comparison tasks.

  # TODO: SHARE THIS!
  set(TSTARGS "-preference=${CMAKE_SOURCE_DIR}/src/base/objs/Preference/TestPreferences")

  # Redirect to the type specific  comparison
  get_filename_component(ext ${truthFile} EXT)
  
  if (${ext} STREQ ".cub")
  elseif (${ext} STREQ ".txt")
  elseif (${ext} STREQ ".csv")
  elseif (${ext} STREQ ".pvl")
  elseif (${ext} STREQ ".net")
  else()
    # TODO: Use DIFF here?
    message(FATAL_ERROR "No rule to check test results of type ${ext}")
  endif()

endfunction()

# TODO: Function to check each test result in the output folder

