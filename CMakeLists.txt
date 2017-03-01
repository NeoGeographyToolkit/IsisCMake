#===============================================================================
#      The main build file for building ISIS using CMake.
#
#===============================================================================
# CMake init

cmake_minimum_required(VERSION 2.8)

# Point cmake to folder containing our additional scripts
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/cmake")

# List the scripts we need
include(AddIsisModule)
include(Utilities)
include(TestSetup)
include(BuildDocs)
include(InstallThirdParty)


# TODO: MOVE THIS!
#include(RunMakeFileTest)
#run_app_makefile_test(${CMAKE_SOURCE_DIR}/src/lro/apps/lronac2isis/tsts/nacl-full/Makefile)
#run_app_makefile_test(${CMAKE_SOURCE_DIR}/src/mro/apps/hisharpen/tsts/default/Makefile)

#===============================================================================
# Project information

project (USGS_ISIS)

# Short and long name of this package
set(PACKAGE            "ISIS")
set(PACKAGE_NAME       "ISGS ISIS")

# Public version number
set(VERSION            "3.5.00.0")
set(PACKAGE_VERSION    ${VERSION})

# Full name and version number
set(PACKAGE_STRING     "${PACKAGE_NAME} ${VERSION}")


# Other release information
set(VERSION_DATE              "2017-01-25")
set(THIRD_PARTY_LIBS_VERSION  "v006")
set(RELEASE_STAGE             "beta") # (alpha, beta, stable)


# Define to the address where bug reports for this package should be sent. 
set(PACKAGE_BUGREPORT  "https://isis.astrogeology.usgs.gov/fixit")

## Define to the one symbol short name of this package.
#set(PACKAGE_TARNAME    "${PACKAGE_NAME}")

# Main website associated with the software package
set(PACKAGE_URL        "https://isis.astrogeology.usgs.gov/")


# Retrieve the OS string we use
get_os_version(osVersionString)
message("Detected OS: ${osVersionString}")


#===============================================================================
# Configuration options - Read from file?

set(BUILD_SHARED_LIBS ON)

set(ISISCPPFLAGS -Wall -ansi -DISIS_LITTLE_ENDIAN=1 -fPIC)

option(buildDocs     "Build the documentation" OFF)
option(buildCore     "Build the core ISIS modules" ON)
option(buildMissions "Build the mission specific modules" ON)


# TODO: Get OS version so we can pick some settings.

# TODO: Additional requirements!

# - For building, need
# export LD_LIBRARY_PATH=/home/smcmich1/code/3rdParty/lib/
# in order for the build tools to work properly.

# - For running the unit tests, requires
# export ISISROOT=/home/smcmich1/code
# and obviously can only be done on the build machine.
#set(ENV{ISISROOT} "${CMAKE_SOURCE_DIR}")

#===============================================================================
# Build the project!

# Set paths to all the required libraries.
include(FindAllDependencies)

# Allow everything to include the 3rd party headers
#message("ALLINCDIRS = ${ALLINCDIRS}")
#message("ALLLIBDIRS = ${ALLLIBDIRS}")
include_directories(${ALLINCDIRS})
link_directories(${ALLLIBDIRS})

# Allow linking to output dir
link_directories(${CMAKE_INSTALL_PREFIX}/lib)

set(CORE_LIB_NAME isis3)

set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "${ALLINCDIRS}")
set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${ALLLIBDIRS}")

# Have binaries use a relative rpath to the lib folder
SET(CMAKE_INSTALL_RPATH "$ORIGIN/../lib;$ORIGIN/../3rdParty/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

#set(THIRD_PARTY_LIB_DIR    "${CMAKE_SOURCE_DIR}/3rdParty/lib")
#set(THIRD_PARTY_PLUGIN_DIR "${CMAKE_SOURCE_DIR}/3rdParty/plugins")

#message("ISISCPPFLAGS = ${ISISCPPFLAGS}")

# TODO: Is there a cleaner way to convert the list to a string?
string (REPLACE ";" " " FLAGS_STR "${ISISCPPFLAGS}")
SET( CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${FLAGS_STR}" )
message("CMAKE_CXX_FLAGS = ${CMAKE_CXX_FLAGS}")

# Needed for add_test
enable_testing()
include(CTest)

# Delete any existing plugin files in the install folder
#  so that we don't get any duplication.
file(GLOB installedPlugins "${CMAKE_INSTALL_PREFIX}/lib/*.plugin")
if(installedPlugins)
  file(REMOVE ${installedPlugins})
endif()

# Add a config file to the bin directory so that QT can find the plugin libraries.
file(WRITE "${CMAKE_INSTALL_PREFIX}/bin/qt.conf" "[Paths]\nPlugins=../lib3rd/plugins/\n")

## TODO: Is this required????!?!?!?!
## Copy the template folder to the install folder.
#file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/templates/gui")
#file(GLOB templates "templates/gui/*")
#copy_files_to_folder(${templates} "${CMAKE_INSTALL_PREFIX}/templates/gui")

# Build the documentation
if (${buildDocs})
  build_docs()
endif()


# All of the source code is in here.
add_subdirectory(src)

# Set up third party libraries for installation
if (${buildCore} OR ${buildMissions})
  install_third_party()
endif()

# Set up this link so that the unit tests can find the plugin
# information they need.
execute_process(COMMAND ln -s "build/src" lib
                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")

# Set up a few top level files for installation
install(FILES IsisPreferences DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES license.txt     DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES version         DESTINATION ${CMAKE_INSTALL_PREFIX})

# Set up format version numbers for the main shared library on install
install(CODE "EXECUTE_PROCESS(COMMAND mv ${CMAKE_INSTALL_PREFIX}/lib/libisis3.s0 ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.0.s0)")
install(CODE "EXECUTE_PROCESS(COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.0.s0 ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.s0)")
install(CODE "EXECUTE_PROCESS(COMMAND ln -s ${CMAKE_INSTALL_PREFIX}/lib/libisis3.5.s0 ${CMAKE_INSTALL_PREFIX}/lib/libisis3.s0)")




