#===============================================================================
#      The main build file for building ISIS using CMake.
#
#===============================================================================
# CMake init

cmake_minimum_required(VERSION 3.1)

# Point cmake to folder containing our additional scripts
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/cmake")

# List the scripts we need
include(AddIsisModule)
include(Utilities)
include(TestSetup)
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

#option(buildDocs     "Build the documentation" OFF)
option(buildCore     "Build the core ISIS modules" ON)
option(buildMissions "Build the mission specific modules" ON)

# TODO: Make this an input option!
if(APPLE)
  set(ENV{ISIS3DATA} "/Users/smcmich1/release_isis/isis3data/")
else()
  set(ENV{ISIS3DATA} "/home/smcmich1/release_isis/isis3data/")
endif()
message("Using ISIS3DATA = $ENV{ISIS3DATA}")

# TODO: Make this an input option!
if(APPLE)
  set(ENV{ISIS3TESTDATA} "/Users/smcmich1/release_isis/testdata/")
else()
  set(ENV{ISIS3TESTDATA} "/home/smcmich1/release_isis/testdata/")
endif()
message("Using ISIS3TESTDATA = $ENV{ISIS3TESTDATA}")
set(ISIS3TESTDATA $ENV{ISIS3TESTDATA})

# Set the default library extension based on the platform
if(APPLE)
  set(SO ".dylib")
else()
  set(SO ".so")
endif()

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
#link_directories(${CMAKE_INSTALL_PREFIX}/lib)

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
set(CTEST_TEST_TIMEOUT 30) # Set the maximum run time for unit and application tests
enable_testing()
include(CTest)

# Delete any existing plugin files in the build folder
#  so that we don't get any duplication.
file(GLOB existingPlugins "${CMAKE_BINARY_DIR}/src/*.plugin")
if(existingPlugins)
  file(REMOVE ${existingPlugins})
endif()

# Clear plugin files so they do not get filled with duplicate entries
if (${buildCore} AND ${buildMissions})
  execute_process(COMMAND rm -f ${CMAKE_BINARY_DIR}/src/*.plugin)
endif()

# Add a config file to the bin directory so that QT can find the plugin libraries.
file(WRITE "${CMAKE_BINARY_DIR}/qt.conf" "[Paths]\nPlugins=../lib3rd/plugins/\n")
install(FILES "${CMAKE_BINARY_DIR}/qt.conf" DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

# The app tests need to see the build executables in the root/bin location!
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/bin)
  execute_process(COMMAND ln -s "${CMAKE_BINARY_DIR}/src" bin
                  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
endif()

# Create an xml folder in the source directory that we will need later
set(sourceXmlFolder ${CMAKE_SOURCE_DIR}/bin/xml)
execute_process(COMMAND mkdir -p ${sourceXmlFolder})

## TODO: Is this required????!?!?!?!
## Copy the template folder to the install folder.
#file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/templates/gui")
#file(GLOB templates "templates/gui/*")
#copy_files_to_folder(${templates} "${CMAKE_INSTALL_PREFIX}/templates/gui")

# All of the source code is in here.
add_subdirectory(src)

# Set up third party libraries for installation
if (${buildCore} OR ${buildMissions})
  install_third_party()
endif()

# TODO: Move the following code to another file!

message("Tweaking build/src directories for unit tests to run.")

# Set up this link so that the unit tests can find the plugin
# information they need.
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/lib)
  execute_process(COMMAND ln -s "${CMAKE_BINARY_DIR}/src" lib
                  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
endif()

# TODO: The GUIs hang, how is this test supposed to work??
# Generate links to a bunch of xml files where the unit tests look for them.
# TODO: Make copies instead?
file(GLOB_RECURSE testXmls "${CMAKE_SOURCE_DIR}/src/unitTest.xml")
foreach(xml ${testXmls})
  get_filename_component(folder ${xml} DIRECTORY)
  get_filename_component(name ${folder} NAME)
  set(linkName test_isis3_${name}.xml)
  if(NOT EXISTS ${sourceXmlFolder}/${linkName})
    execute_process(COMMAND ln -s "${xml}" "${linkName}"
                    WORKING_DIRECTORY ${sourceXmlFolder})
  endif()
endforeach()

# Link to all application xmls from the bin/xml folder
file(GLOB_RECURSE allXmls "${CMAKE_SOURCE_DIR}/src/*.xml")
message("allXmls = ${allXmls}")
foreach(xml ${allXmls})
  string(FIND ${xml} "/apps/" pos)
  if(NOT ${pos} EQUAL -1 )
    get_filename_component(name ${xml} NAME)
    if (NOT EXISTS ${sourceXmlFolder}/${name})
      execute_process(COMMAND ln -s "${xml}" "${name}"
                      WORKING_DIRECTORY ${sourceXmlFolder})
    endif()
  endif()
endforeach()
# TODO: Link to all app xml files in the {root}/bin/xml directory.  Needed for tests!


# Create a link from the build/src directory to each folder in 3rdPartyLibs/plugins
# TIP: Set "export QT_DEBUG_PLUGINS=1" to help debug plugin errors.
foreach(plugin ${THIRDPARTYPLUGINFOLDERS})
  get_filename_component(pluginName ${plugin} NAME)
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/src/${pluginName})
    execute_process(COMMAND ln -s "${plugin}" ${pluginName}
                    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/src")
  endif()
endforeach()


# Set up documentation build
# - This script will be called when "make docs" is run.
# - All desired variables must be passed to the script.
add_custom_target(docs COMMAND ${CMAKE_COMMAND}   -DPROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}  -DDOXYGEN=${DOXYGEN}  -DXALAN=${XALAN} -DLATEX=${LATEX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -P ${CMAKE_MODULE_PATH}/BuildDocs.cmake)


# Custom build target to clean out everything that gets added to the source
#  directory during the build process.
# - Only a few things are added in order to make the tests work properly.
add_custom_target(clean_source COMMAND rm -rf ${CMAKE_SOURCE_DIR}/bin; rm -rf ${CMAKE_SOURCE_DIR}/lib)

# Set up a few top level files for installation
install(FILES IsisPreferences DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES license.txt     DESTINATION ${CMAKE_INSTALL_PREFIX})
install(FILES version         DESTINATION ${CMAKE_INSTALL_PREFIX})

# Trigger all post-install behavior
# - The only way to make this run post-install in CMake is to add a subdirectory at
#   the end of this file containing all the post-install commands in CMakeLists.txt
add_subdirectory(cmake)

