
# This file contains everything that should be exectuted AFTER the installation 
# step has completed.

message("Setting up post-install behavior...")

# Set up format version numbers for the main shared library on install
install(CODE "EXECUTE_PROCESS(COMMAND mv ${CMAKE_INSTALL_PREFIX}/lib/libisis3${SO} ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.0${SO})")
install(CODE "EXECUTE_PROCESS(COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.0${SO} ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5${SO})")
install(CODE "EXECUTE_PROCESS(COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5${SO} ${CMAKE_INSTALL_PREFIX}/lib/libisis3${SO})")

# On OSX, need to correct all the paths encoded in each of the distributed library files so
#  that they properly find the distruted files using relative paths.
if (APPLE)
  # Call the correction script on each folder containing libraries
  install(CODE "EXECUTE_PROCESS(COMMAND python ${CMAKE_SOURCE_DIR}/scripts/finalizeInstalledOsxRpaths.py ${CMAKE_INSTALL_PREFIX}/lib)")
  install(CODE "EXECUTE_PROCESS(COMMAND python ${CMAKE_SOURCE_DIR}/scripts/finalizeInstalledOsxRpaths.py ${CMAKE_INSTALL_PREFIX}/3rdParty/lib resetRpath)")
  # TODO: bin folder also?
endif()



