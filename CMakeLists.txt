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


#===============================================================================
# Build the project!

# Set paths to all the required libraries.
include(FindAllDependencies)

# Allow everything to include the 3rd party headers
#message("ALLINCDIRS = ${ALLINCDIRS}")
message("ALLLIBDIRS = ${ALLLIBDIRS}")
include_directories(${ALLINCDIRS})
link_directories(${ALLLIBDIRS})

set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "${ALLINCDIRS}")
set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${ALLLIBDIRS}")

#set(THIRD_PARTY_LIB_DIR    "${CMAKE_SOURCE_DIR}/3rdParty/lib")
#set(THIRD_PARTY_PLUGIN_DIR "${CMAKE_SOURCE_DIR}/3rdParty/plugins")




# All of the source code is in here.
add_subdirectory(src)











