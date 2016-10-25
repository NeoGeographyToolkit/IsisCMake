


# This macro returns a list of all the subdirectories in the given directory
MACRO(SUBDIRLIST curdir result)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
      LIST(APPEND dirlist ${curdir}/${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

#------------------------------------------------------------

# TODO: Can we consolidate the following three functions?

# Generate ui_*.h files from *.ui files using QT tool uic.
function( generate_ui_files UI_GEN_OUT folder)

  # Finds all .ui files in the current dir
  file(GLOB UI_INPUT "${folder}/*.ui")

  # If no .ui files in this folder we are finished.
  list(LENGTH UI_INPUT numFiles)
  if (${numFiles} EQUAL 0)
    set(${UI_GEN_OUT} "" PARENT_SCOPE)
    return()
  endif()

  #message("FOUND UI FILES ${UI_INPUT}")

  # Set where generated files go to and add that directory to the include path
  set(UI_GEN_DIR ${CMAKE_CURRENT_BINARY_DIR})
  include_directories(${UI_GEN_DIR})

  # For each input protobuf file
  foreach(UI_FILE ${UI_INPUT})
    # Get the name of the file without extension
    get_filename_component(UI_NAME ${UI_FILE} NAME_WE)
    
    # Add the generated file to UI_GEN variable
    set(OUT_UI_FILE "${UI_GEN_DIR}/ui_${UI_NAME}.h")
    set(UI_GEN       ${UI_GEN} ${OUT_UI_FILE})

    # Add the custom command that will generate this file
    # - The generated files will be put in the CMake build directory, 
    #   not the source tree    
    add_custom_command(OUTPUT   ${OUT_UI_FILE}
                       COMMAND  ${UIC}  ${UI_FILE} -o ${OUT_UI_FILE}
                       DEPENDS  ${UI_FILE}
                       WORKING_DIRECTORY ${folder}
                       COMMENT "Generating UI headers...")

  endforeach()

  #message("UI Output files: ${UI_GEN}")
  set(${UI_GEN_OUT} ${UI_GEN} PARENT_SCOPE) # Set up output variable

endfunction(generate_ui_files)

#------------------------------------------------------------

# Generate moc_*.cpp files from *.h files using Q_OBJECT using the moc tool.
function( generate_moc_files MOC_GEN_OUT folder)

  # Finds all .h files in the current dir including the text Q_OBJECT
  file(GLOB CANDIDATE_FILES "${folder}/*.h")
  set(MOC_INPUT)
  foreach(f ${CANDIDATE_FILES})
    message("searching =  ${f}")
    exec_program("grep" ARGS "Q_OBJECT ${f}"
                    OUTPUT_VARIABLE result
                    RETURN_VALUE code)
    message("code = ${code}")
    message("result = ${result}")
    if(${code} STREQUAL "0")
      set(MOC_INPUT ${MOC_INPUT} ${f})
    endif()
  endforeach()


  # If no Q_OBJECT files in this folder we are finished.
  list(LENGTH MOC_INPUT numFiles)
  if (${numFiles} EQUAL 0)
    set(${MOC_GEN_OUT} "" PARENT_SCOPE)
    return()
  endif()

  message("FOUND MOC FILES ${MOC_INPUT}")

  # Set where generated files go to and add that directory to the include path
  set(MOC_GEN_DIR ${CMAKE_CURRENT_BINARY_DIR})
  include_directories(${MOC_GEN_DIR})

  # For each input protobuf file
  foreach(MOC_FILE ${MOC_INPUT})
    # Get the name of the file without extension
    get_filename_component(MOC_NAME ${MOC_FILE} NAME_WE)
    
    # Add the generated file to UI_GEN variable
    set(OUT_MOC_FILE "${MOC_GEN_DIR}/moc_${MOC_NAME}.cpp")
    set(MOC_GEN       ${MOC_GEN} ${OUT_MOC_FILE})

    # Add the custom command that will generate this file
    # - The generated files will be put in the CMake build directory, 
    #   not the source tree    
    add_custom_command(OUTPUT   ${OUT_MOC_FILE}
                       COMMAND  ${MOC}  ${MOC_FILE} -o ${OUT_MOC_FILE}
                       DEPENDS  ${MOC_FILE}
                       WORKING_DIRECTORY ${folder}
                       COMMENT "Generating MOC files...")

  endforeach()

  message("MOC Output files: ${MOC_GEN}")
  set(${MOC_GEN_OUT} ${MOC_GEN} PARENT_SCOPE) # Set up output variable

endfunction(generate_moc_files)


#------------------------------------------------------------

# Generate ProtoBuf output files for an obj folder.
# ${PROTOC} must point to the protobuf tool
function(generate_protobuf_files PROTO_GEN_OUT folder)

  # Finds all .proto files in the current dir
  file(GLOB PROTO_INPUT "${folder}/*.proto")

  # If no .proto files in this folder we are finished.
  list(LENGTH PROTO_INPUT numFiles)
  if (${numFiles} EQUAL 0)
    set(${PROTO_GEN_OUT} "" PARENT_SCOPE)
    return()
  endif()

  #message("FOUND PROTOBUFF FILES ${PROTO_INPUT}")


  # Set where generated files go to and add that directory to the include path
  set(PROTO_GEN_DIR ${CMAKE_CURRENT_BINARY_DIR})
  include_directories(${PROTO_GEN_DIR})

  # For each input protobuf file
  foreach(PROTO_FILE ${PROTO_INPUT})
    # Get the name of the file without extension
    get_filename_component(PROTO_NAME ${PROTO_FILE} NAME_WE)
    
    # Add the two generated files to PROTO_GEN variable
    set(PROTO_GEN ${PROTO_GEN}
        ${PROTO_GEN_DIR}/${PROTO_NAME}.pb.h
        ${PROTO_GEN_DIR}/${PROTO_NAME}.pb.cc)
  endforeach()

  # Add the custom command that will generate all the files
  # - The generated files will be put in the CMake build directory, not the source tree.
  #message("Protobuff Output files: ${PROTO_GEN}")
  add_custom_command(OUTPUT   ${PROTO_GEN}
                     COMMAND  ${PROTOC} --proto_path ${folder} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTO_INPUT}
                     DEPENDS  ${PROTO_INPUT}
                     WORKING_DIRECTORY ${folder}
                     COMMENT "Generating Protocol Buffers...")

  set(${PROTO_GEN_OUT} ${PROTO_GEN} PARENT_SCOPE) # Set up output variable
endfunction(generate_protobuf_files)

