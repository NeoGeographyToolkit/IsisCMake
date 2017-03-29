########################################################################
#                 USGS ISIS CMake build system notes                   #
########################################################################

# Introduction ==========================================================


# Overview --------------------------------------------------------------

This build system was developed for the post-3.5.0 version of the USGS
ISIS software.  The intent is to fully replace the existing Makefile
based build system with something that is easier to update and maintain.


# Requirements --------------------------------------------------------------

- Tested Operating Systems

Ubuntu 14, CentOS 7, and OSX 10.

- Tested Compilers

Linux: GCC 4.8.4
OSX:   Clang 7.3.0

- Other software:

CMake version 3.5 or higher. TODO: Verify version!

The 3rd party library requirements for ISIS are the same as they
are with the old Makefile build system.


# Using the build system =======================================================


# Running the build --------------------------------------------------------

Using the new build system is very similar to building other CMake based
software.  Start by creating a new build folder, a common choice is a 
folder named "build" in the same folder as the source folder.  By 
using a new folder you can easily delete it to get a completely clean
build and you won't introduce any new files into your source folder.
Change directory into the new folder, then run cmake pointed at the top
level of the ISIS folder.  The following options are supported by the
build system:

Standard CMake options:
CMAKE_INSTALL_PREFIX = Specify where the installation folder.

Special options for ISIS:
isis3Data = Specify where the downloadable ISIS data is located.
isis3TestData = Specify the location containing the special ISIS application 
test data.
buildCore = Set to OFF to skip building any code.  TODO: Force buildMissions=OFF
buildMissions = Set to OFF to skip building this code.

TODO options: 
disable building local folder?
makefile test output directory
buildStatic = Set to OFF to disable building the core static library.

Once CMake finishes running, run "make" to build the code, "make install" to 
install it to the output, and "make docs" to generate the documentation files
in the installation folder.  A full set of commands may look like:

cd ~/isis_code
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=~/isis_install -Disis3Data=~/isis3data \
-Disis3TestData=~/isis3TestData
make
make install
make docs

The build system also accepts the "make clean_source" command which removes
all files and folders that need to be created in the top level of the ISIS
folder in order to run the unit tests.


# Running tests --------------------------------------------------------

The CMake build system relies on the CTest tool, which should be included with
CMake, to handle unit, application, and module tests.  To run the tests, simply
run the ctest command from the build directory.  The CTest tool has a number of
useful built-in options to help run the tests which you can see by running 
"ctest --help".  Note that due to the naming convention applied to the tests in
the build system you can choose to run only a certain category of tests by adding
the options "-R _unit_", "-R _app_", or "-R _module_".

TODO: Specify location of output files.


# Building the documentation --------------------------------------------------------

To generate the documentation, just run "make docs" after running CMake.  All of the
relevant documentation should be placed in the installation folder.  The third party 
tools "xalan", "doxygen", and "latex" must be available in order to generate the
documentation.

# Cleaning up the build -------------------------------------------------------------

To completely clean up the build just delete the entire build folder and create a new
one.  You can also run "make clean" to remove files generated during the build as 
opposed to files generated while running CMake.  To remove all cmake generated files
from the source directory (there should only be a couple folders) run "make clean_source".


# Build system details =======================================================

# File listing ----------------------------------------------------------------

The CMake build system consists of 15 files, each of which is described below.

README.txt = This file!  Contains a description of the build system.

CMakeLists.txt = The top level build file.  Handles input options, defines project
characteristics, sets up some required links, and calls all of the other required modules.

src/CMakeLists.txt = The lower level build file.  This defines which module folders
are used to create libraries.  There is one core library and one library per mission
directory.

In the /cmake folder:

AddIsisModule.cmake       = Functions for parsing a module folder and adding all 
                            of the components to the build.
BuildDocs.cmake           = This file handles tho documentation production.
CodeGeneration.cmake      = Functions for generating moc, uic, and protobuf files.
FindAllDependencies.cmake = Identify all of the required 3rd party libraries.
InstallThirdParty.cmake   = Handle transfer of 3rd party libraries to the install folder.
RunMakeFileTest.cmake     = Script that is called to execute an app or module (Makefile based) test.
RunUnitTest.cmake         = Script that is called to execute a unit test.
TestSetup.cmake           = Helper functions for setting up tests.
Utilities.cmake           = Miscellaneous functions used in the other files.

In the /scripts folder:

fetchRequiredData.py            = Script for fetching a subset of the ISIS mission 
                                  data for the purpose of running unit tests.  
                                  TODO: Remove from final version.
finalizeInstalledOsxRpaths.py   = Script to correct the RPaths of OSX libraries 
                                  after they are installed.
IsisInlineDocumentBuild_mod.xsl = An old documentation build file modified for 
                                  use by the CMake build system.






