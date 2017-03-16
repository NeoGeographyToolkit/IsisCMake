
#INSTALL3P      := $(RSYNC)
#INSTALL3POPTS  := -aq
#PATCHELF       := patchelf
#RM             := /bin/rm -f

# Library portion of the installation
function(install_third_party_libs)

  # Where all the library files will go
  set(installLibFolder "${CMAKE_INSTALL_PREFIX}/3rdParty/lib")


  # Loop through all the library files in our list
  foreach(library ${THIRDPARTYLIBS})
    
    # Copy file to output directory    
    file(RELATIVE_PATH relPath "${thirdPartyDir}/lib" ${library})
    
    #message("RELATIVE_PATH = ${relPath}")
    
    execute_process(COMMAND readlink ${library} OUTPUT_VARIABLE link)    
    if ("${link}" STREQUAL "")
      # Copy original files and framework folders
      message("Install lib file ${library}")
      string(FIND ${library} "framework" position)
      if(NOT ${position} EQUAL -1)
        INSTALL(DIRECTORY ${library} DESTINATION ${installLibFolder})
      else()
        INSTALL(FILES ${library} DESTINATION ${installLibFolder})
      endif()
    else()
      # Recreate symlinks
      string(REGEX REPLACE "\n$" "" link "${link}") # Strip trailing newline
      # TODO: Why does cmake link command not work?
      #install_symlink(${link} ${installLibFolder}/${relPath})
      #message("name = ${installLibFolder}/${relPath} target = ${link}")
      install(CODE "EXECUTE_PROCESS(COMMAND ln -s ${link} ${installLibFolder}/${relPath})")
    endif()
       
	  
	  
	  
	  
	  # LINUX
	  if(NOT APPLE)
	  
	    # TODO: Make sure RPaths are correct!
	  
	    #for file in $$library; do                                        \
	    #  localFile=$(ISISROOT)/3rdParty/lib/`basename $$file`;          \ 
	    #  # If localfile is a symbolic link
	    #  if [ ! -L "$$localFile" ]; then                                \
	    #    existingRpath=`$(PATCHELF) --print-rpath "$$localFile" 2>&- | \
	    #        cut -d '/' -f2-4`;                                       \
	    #    dollar='$$';                                                 \
	    #    newRpath=`echo "$${dollar}ORIGIN"`;                          \
	    #    if [ "$$existingRpath" == "usgs/pkgs/local" ]; then          \
	    #      echo $(CURTIMESTAMP) "    Patching [" `basename $$file` "]"; \
	    #      $(PATCHELF) --set-rpath "$$newRpath" $$localFile;          \
	    #    fi;                                                          \
	    #  fi;                                                             \
	    #done;                                                             \
	   
	  endif(NOT APPLE)
  endforeach()
  
  # TODO:
  # OSX
	#if [ "$(HOST_ARCH)" == "Darwin" ]; then                              \

  #  # Add user write ability to these libraries - why??
	#  chmod u+w $(ISISROOT)/3rdParty/lib/libcrypto.*.dylib;              \
	#  chmod u+w $(ISISROOT)/3rdParty/lib/libssl.*.dylib;                 \
	  
	# --> Note this script call used for OSX!
	#  $(ISISROOT)/scripts/SetRunTimePath --libs                          \
	#    --libmap=$(ISISROOT)/scripts/darwin_lib_paths.lis                \
	#    --liblog=DarwinLibs.lis --update                                 \
	#    --relocdir=$(ISISROOT)/3rdParty/lib:$(ISISROOT)/3rdParty         \
	#    --errlog=DarwinErrors.lis                                        \
	#    `find $(ISISROOT)/3rdParty/lib -name '*.dylib*' -type f`          \
	#    > /dev/null;                                                     \
	    
	#  $(ISISROOT)/scripts/SetRunTimePath --libs                          \
	#     --libmap=$(ISISROOT)/scripts/qt_paths.lis                       \
  #     --liblog=DarwinLibs.lis                                         \
	#     --relocdir=$(ISISROOT)/3rdParty/lib:$ISISROOT/3rdParty          \
  #     --update                                                        \
	#    `find $(ISISROOT)/3rdParty/lib -name '[Qq]*' -print              \
	#    -mindepth 3 -maxdepth 4 -type f` > /dev/null;                    \
	    
	#  chmod u-w $(ISISROOT)/3rdParty/lib/libcrypto.*.dylib;              \
	#  chmod u-w $(ISISROOT)/3rdParty/lib/libssl.*.dylib;                 \
	  
	#  if [ -f "DarwinErrors.lis" ]; then                                 \
	#    cat DarwinErrors.lis;                                            \
	#  fi;                                                                \
	#  $(RM) DarwinErrors.lis DarwinLibs.lis;                             \
	#fi                 
	                                                
endfunction()



# Plugin portion of the installation
function(install_third_party_plugins)

  # Where all the library files will go
  set(installPluginFolder "${CMAKE_INSTALL_PREFIX}/3rdParty/plugins")

  # Copy all of the plugin files
	foreach(plugin ${THIRDPARTYPLUGINS})
	  file(RELATIVE_PATH relPath "${thirdPartyDir}/plugins" ${plugin})
	  get_filename_component(relPath ${relPath} DIRECTORY) # Strip filename
	  INSTALL(FILES ${plugin} DESTINATION ${installPluginFolder}/${relPath})
	  #INSTALL(FILES ${plugin} DESTINATION ${installPluginFolder})
	endforeach()
	
	# TODO
	# OSX
	#if [ "$(HOST_ARCH)" == "Darwin" ]; then                              \
	#  $(ISISROOT)/scripts/SetRunTimePath --bundles                       \
	#    --libmap=$(ISISROOT)/scripts/qt_plugins_paths.lis                \
	#    --liblog=DarwinLibs.lis --update                                 \
	#    --relocdir=$(ISISROOT)/3rdParty/lib:$(ISISROOT)/3rdParty         \
	#    --errlog=DarwinErrors.lis                                        \
  #    `find $(ISISROOT)/3rdParty/plugins -name '*.bundle' -type f`     \
  #    `find $(ISISROOT)/3rdParty/plugins -name '*.dylib' -type f`      \
  #    > /dev/null;                                                     \
	#  if [ -f "DarwinErrors.lis" ]; then                                 \
	#    cat DarwinErrors.lis;                                            \
	#  fi;                                                                \
	#  $(RM) DarwinErrors.lis DarwinLibs.lis;                             \
	#fi

endfunction()


# Install all third party stuff
function(install_third_party)

  # The files are available pre-build but are not copied until make-install is called.
  message("Setting up 3rd party lib installation...")
  install_third_party_libs()
  
  message("Setting up 3rd party plugin installation...")
  install_third_party_plugins()

  INSTALL(FILES "${CMAKE_SOURCE_DIR}/3rdParty/lib/README" 
          DESTINATION ${CMAKE_INSTALL_PREFIX}/3rdParty/lib)
  # TODO: This file is missing?
  #INSTALL(FILES "${CMAKE_SOURCE_DIR}/3rdParty/plugins/README" 
  #        DESTINATION ${CMAKE_INSTALL_PREFIX}/3rdParty/plugins)

endfunction()


#clean:
#	rm -f lib/lib*.so* lib/lib*.dylib* lib/lib*.a
#	cd lib && rm -rf *.framework
#	$(RM) -rf license
#	@for plugs in plugins/*; do \
#	  if [ -d $$plugs -a $$plugs != "plugins/CVS" ]; \
#	  then \
#	    $(RM) -rf $$plugs; \
#	  fi \
#	done;

# TODO: Do we need this?
#license:
#	echo $(CURTIMESTAMP) "  Obtaining licenses";                         \
#	$(RSYNC) -a /usgs/pkgs/local/$(ISISLOCALVERSION)/license/            \
#	  $(ISISROOT)/3rdParty/license/
	



