

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

  message("FOUND PROTOBUFF FILES ${PROTO_INPUT}")


  # TODO: Verify this works!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
  message("Protobuff Output files: ${PROTO_GEN}")
  add_custom_command(OUTPUT   ${PROTO_GEN}
                     COMMAND  ${PROTOC} --proto_path ${folder} --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${PROTO_INPUT}
                     DEPENDS  ${PROTO_INPUT}
                     WORKING_DIRECTORY ${folder}
                     COMMENT "Generating Protocol Buffers...")

  set(${PROTO_GEN_OUT} ${PROTO_GEN} PARENT_SCOPE) # Set up output variable
endfunction(generate_protobuf_files)

