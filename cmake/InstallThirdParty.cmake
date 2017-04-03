#===========================================================================
# Code for installing the third part libraries to the output folder.
#===========================================================================

# Library portion of the installation
function(install_third_party_libs)

  # Where all the library files will go
  set(installLibFolder "${CMAKE_INSTALL_PREFIX}/3rdParty/lib")

  # Loop through all the library files in our list
  foreach(library ${THIRDPARTYLIBS})
    
    # Copy file to output directory    
    file(RELATIVE_PATH relPath "${thirdPartyDir}/lib" ${library})
    
    # Check if the file is a symlink
    execute_process(COMMAND readlink ${library} OUTPUT_VARIABLE link)    
    if ("${link}" STREQUAL "")

      # Copy original files and framework folders
      if(IS_DIRECTORY ${library})
        INSTALL(DIRECTORY ${library} DESTINATION ${installLibFolder})
      else()
        INSTALL(FILES ${library} DESTINATION ${installLibFolder})
      endif()
      
    else()
      # Recreate symlinks
      string(REGEX REPLACE "\n$" "" link "${link}") # Strip trailing newline
      install(CODE "EXECUTE_PROCESS(COMMAND ln -fs ${link} ${installLibFolder}/${relPath})")
    endif()      

  endforeach()
                                                
endfunction()



# Plugin portion of the installation
function(install_third_party_plugins)

  # Where all the plugin files will go
  set(installPluginFolder "${CMAKE_INSTALL_PREFIX}/3rdParty/plugins")

  # Copy all of the plugin files
  foreach(plugin ${THIRDPARTYPLUGINS})
    file(RELATIVE_PATH relPath "${thirdPartyDir}/plugins" ${plugin})
    get_filename_component(relPath ${relPath} DIRECTORY) # Strip filename
    INSTALL(FILES ${plugin} DESTINATION ${installPluginFolder}/${relPath})
  endforeach()
	
endfunction()


# Install all third party libraries and plugins
function(install_third_party)

  # The files are available pre-build but are not copied until make-install is called.
  message("Setting up 3rd party lib installation...")
  install_third_party_libs()
  
  message("Setting up 3rd party plugin installation...")
  install_third_party_plugins()

  # Finish miscellaneous file installation
  INSTALL(FILES "${CMAKE_SOURCE_DIR}/3rdParty/lib/README" 
          DESTINATION ${CMAKE_INSTALL_PREFIX}/3rdParty/lib)
          
  # TODO: This file is missing?
  #INSTALL(FILES "${CMAKE_SOURCE_DIR}/3rdParty/plugins/README" 
  #        DESTINATION ${CMAKE_INSTALL_PREFIX}/3rdParty/plugins)

endfunction()



