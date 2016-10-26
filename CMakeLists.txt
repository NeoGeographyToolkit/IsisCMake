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

#===============================================================================
# Configuration options - Read from file?

set(BUILD_SHARED_LIBS ON)

set(ISISCPPFLAGS -Wall -ansi -DISIS_LITTLE_ENDIAN=1 -fPIC)

# TODO: Get OS version so we can pick some settings.

# TODO: Additional requirements!

# - For building, need
# export LD_LIBRARY_PATH=/home/smcmich1/code/3rdParty/lib/
# in order for the build tools to work properly.

# - For running the unit tests, requires
# export ISISROOT=/home/smcmich1/code
# and obviously can only be done on the build machine.


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

set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "${ALLINCDIRS}")
set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${ALLLIBDIRS}")

# TODO: Deal with some hard coded path issues:
# - $ISISROOT/src/blah/blah
# - Copy 3rd party libs to install dir?

# Have binaries use a relative rpath to the lib folder
SET(CMAKE_INSTALL_RPATH "$ORIGIN/../lib;$ORIGIN/../lib3rd")

#set(THIRD_PARTY_LIB_DIR    "${CMAKE_SOURCE_DIR}/3rdParty/lib")
#set(THIRD_PARTY_PLUGIN_DIR "${CMAKE_SOURCE_DIR}/3rdParty/plugins")

#message("ISISCPPFLAGS = ${ISISCPPFLAGS}")

# TODO: Is there a cleaner way to convert the list to a string?
string (REPLACE ";" " " FLAGS_STR "${ISISCPPFLAGS}")
SET( CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${FLAGS_STR}" )
message("CMAKE_CXX_FLAGS = ${CMAKE_CXX_FLAGS}")

# Needed for add_test
#enable_testing()
include(CTest)

# Delete any existing plugin files in the installation folder
#  so that we don't get any duplication.
file(GLOB installedPlugins "${CMAKE_INSTALL_PREFIX}/lib/*.plugin")
file(REMOVE ${installedPlugins})

# All of the source code is in here.
add_subdirectory(src)








