#===============================================================================
#        High level script to find all required 3rd party dependencies
#
#===============================================================================


# TODO: Indent all!

set(thirdPartyDir "${CMAKE_SOURCE_DIR}/3rdParty")

set(INCLUDE_DIR "${thirdPartyDir}/include")
set(LIB_DIR     "${thirdPartyDir}/lib")
set(PLUGIN_DIR  "${thirdPartyDir}/plugins")
set(BIN_DIR     "${thirdPartyDir}/bin")

# TODO: Any way to set this automatically?
#set(ENV{LD_LIBRARY_PATH} ${LIB_DIR})

set(XALAN   "${BIN_DIR}/Xalan")
#set(LATEX   "${BIN_DIR}/latex") # MISSING
#set(DOXYGEN "${BIN_DIR}/doxygen") # MISSING
set(DOXYGEN "/home/smcmich1/doxygen-1.8.8/bin/doxygen")
# Also need the DOT tool for doxygen.

#verify_file_exists(${XALAN})
#verify_file_exists(${LATEX})
#verify_file_exists(${DOXYGEN})

# Other packages that had to be installed:
# libmng-dev

#---------------------------------------------------------------------------
# Set up for Qt
#---------------------------------------------------------------------------
# *Most* of the folders in the main QT folder are needed as an include directory
set(qtDir "${INCLUDE_DIR}/qt/qt5.6.0")
set(qtIncludes  Qt
                QtCore
                QtAssistant
                QtConcurrent
                QtDBus
                QtGui
                QtMultimedia
                QtMultimediaWidgets
                QtNetwork
                QtOpenGL # Needed to install mesa-common-dev for this!
                QtPositioning
                QtPrintSupport
                QtQml
                QtQuick
                QtScript
                QtScriptTools
                QtSensors
                QtSql
                QtSvg
                QtTest
                QtWebChannel
                QtWebEngine
                QtWebEngineWidgets
                QtWidgets
                QtXml
                QtXmlPatterns)

set(QTINCDIR ${qtDir})
foreach(f ${qtIncludes})
  set(QTINCDIR ${QTINCDIR} ${qtDir}/${f}) 
endforeach()

# TODO: Update include paths for mac?

# One set of libs is for link statements, the other is for installation.

if(APPLE)

  # TODO: Clean up by using this!
  set(QTLIBDIR ${LIB_DIR}/qt5)

  # Use find_library cmake function to find the QT frameworks
  set(QTLIB)
  set(QT_DYNAMIC_LIBS)
  set(qtLibNames QtXmlPatterns QtXml QtNetwork
                 QtSql QtGui QtCore QtSvg 
                 QtTest QtWebKit QtOpenGL 
                 QtConcurrent QtDBus 
                 QtMultimedia QtMultimediaWidgets 
                 QtNfc QtPositioning QtPrintSupport 
                 QtQml QtQuick QtQuickParticles 
                 QtQuickTest QtQuickWidgets QtScript 
                 QtScriptTools QtSensors QtSerialPort 
                 QtWebKitWidgets QtWebSockets QtWidgets 
                 QtTest QtWebChannel QtWebEngine QtWebEngineCore QtWebEngineWidgets)
  foreach(qtName ${qtLibNames})
    set(temp "${qtName}-NOTFOUND") # Work around CMake bug!
    find_library(temp ${qtName} PATHS ${QTLIBDIR})
    # Update link and lib list in the loop
    set(QTLIB ${QTLIB} ${temp})
    set(QT_DYNAMIC_LIBS ${QT_DYNAMIC_LIBS} ${QTLIBDIR}/${qtName}.framework)
  endforeach()
  
  set(QTLIBDIR ${QT_DYNAMIC_LIBS}) # The same in this case since frameworks are folders

  message("QTLIB = ${QTLIB}")

else() # Linux

  set(QTLIBDIR ${LIB_DIR})

  set(QTLIB    -lQtCore -lQt5Concurrent -lQt5XmlPatterns -lQt5Xml -lQt5Network -lQt5Sql -lQt5Gui -lQt5PrintSupport -lQt5Positioning -lQt5Qml -lQt5Quick -lQt5Sensors -lQt5Svg -lQt5Test -lQt5OpenGL -lQt5Widgets -lQt5Multimedia -lQt5MultimediaWidgets -lQt5WebChannel -lQt5WebEngine -lQt5WebEngineWidgets -lQt5DBus)

  set(QT_DYNAMIC_LIBS)
  set(QT_DYNAMIC_IN  ${LIB_DIR}/libQt5Concurrent.so
                   ${LIB_DIR}/libQt5Core.so
                   ${LIB_DIR}/libQt5DBus.so
                   ${LIB_DIR}/libQt5Gui.so
                   ${LIB_DIR}/libQt5Multimedia.so
                   ${LIB_DIR}/libQt5MultimediaWidgets.so
                   ${LIB_DIR}/libQt5Network.so
                   ${LIB_DIR}/libQt5OpenGL.so
                   ${LIB_DIR}/libQt5Positioning.so
                   ${LIB_DIR}/libQt5PrintSupport.so
                   ${LIB_DIR}/libQt5Qml.so
                   ${LIB_DIR}/libQt5Quick.so
                   ${LIB_DIR}/libQt5Sensors.so
                   ${LIB_DIR}/libQt5Sql.so
                   ${LIB_DIR}/libQt5Svg.so
                   ${LIB_DIR}/libQt5Test.so
                   ${LIB_DIR}/libQt5WebChannel.so
                   ${LIB_DIR}/libQt5WebEngineCore.so
                   ${LIB_DIR}/libQt5WebEngine.so
                   ${LIB_DIR}/libQt5WebEngineWidgets.so
                   ${LIB_DIR}/libQt5Widgets.so
                   ${LIB_DIR}/libQt5XcbQpa.so
                   ${LIB_DIR}/libQt5Xml.so
                   ${LIB_DIR}/libQt5XmlPatterns.so)
  foreach(f ${QT_DYNAMIC_IN})
    set(QT_DYNAMIC_LIBS ${QT_DYNAMIC_LIBS} ${f} ${f}.5 ${f}.5.6.0)
  endforeach()
endif()
#message("QT_DYNAMIC_LIBS = ${QT_DYNAMIC_LIBS}")
#message("QTLIBDIR = ${QTLIBDIR}")
#message("QTLIB = ${QTLIB}")

# Binary paths
set(UIC "${BIN_DIR}/uic")
set(MOC "${BIN_DIR}/moc")
set(RCC "${BIN_DIR}/rcc")

verify_file_exists(${UIC})
verify_file_exists(${MOC})
verify_file_exists(${RCC})

# TODO: Is this required?  Looks like QT needs to be properly installed for this to work.
#set(Qt5Widgets_DIR ${LIB_DIR}/cmake/Qt5Widgets)
#message("Qt5Widgets_DIR = ${Qt5Widgets_DIR}")
#find_package(Qt5Widgets)

# Had to manually install required dependencies libsnappy-dev and libsrtp-dev

#---------------------------------------------------------------------------
# Set up for Qwt
#---------------------------------------------------------------------------
set(QWTINCDIR "${INCLUDE_DIR}/qwt")

if(APPLE)

  set(QWTLIBDIR ${LIB_DIR}/qwt)

  # Use dedicated cmake code to find the QT frameworks
  find_library(frameQwt Qwt PATHS ${QWTLIBDIR})
  set(QWTLIB ${frameQwt})
else()
  
  set(QWTLIBDIR "${LIB_DIR}")
  set(QWTLIB    "-lqwt")
endif()


#---------------------------------------------------------------------------
# Set up for Xerces 
#---------------------------------------------------------------------------
set(XERCESINCDIR ${INCLUDE_DIR}/xercesc ${INCLUDE_DIR}/xercesc/xercesc-3.1.2)
set(XERCESLIBDIR "${LIB_DIR}")
set(XERCESLIB    "-lxerces-c")

#---------------------------------------------------------------------------
# Set up for geotiff 
#---------------------------------------------------------------------------
set(GEOTIFFINCDIR "${INCLUDE_DIR}/geotiff")
set(GEOTIFFLIBDIR "${LIB_DIR}")
set(GEOTIFFLIB    "-lgeotiff")

#---------------------------------------------------------------------------
# Set up for Tiff 
#---------------------------------------------------------------------------
set(TIFFINCDIR "${INCLUDE_DIR}/tiff/tiff-4.0.5")
set(TIFFLIBDIR "${LIB_DIR}")
set(TIFFLIB    "-ltiff")

#---------------------------------------------------------------------------
# Set up for naif dsk and cspice libraries
#---------------------------------------------------------------------------
set(NAIFINCDIR "${INCLUDE_DIR}/naif")
set(NAIFLIBDIR "${LIB_DIR}")
if(APPLE)
  set(NAIFLIB    "-ldsklib -lcspice")
else()
  set(NAIFLIB    "-ldsk -lcspice")
endif()

#---------------------------------------------------------------------------
# Set up for TNT
#---------------------------------------------------------------------------
set(TNTINCDIR ${INCLUDE_DIR}/tnt  ${INCLUDE_DIR}/tnt/tnt126 ${INCLUDE_DIR}/tnt/tnt126/tnt)
set(TNTLIBDIR)
set(TNTLIB)

#---------------------------------------------------------------------------
# Set up for JAMA
#---------------------------------------------------------------------------
set(JAMAINCDIR ${INCLUDE_DIR}/jama ${INCLUDE_DIR}/jama/jama125)
set(JAMALIBDIR)
set(JAMA)

#---------------------------------------------------------------------------
# Set up for GEOS
#---------------------------------------------------------------------------
set(GEOSINCDIR ${INCLUDE_DIR}/geos ${INCLUDE_DIR}/geos/geos3.5.0)
set(GEOSLIBDIR "${LIB_DIR}")
set(GEOSLIB    "-lgeos-3.5.0 -lgeos_c")

#---------------------------------------------------------------------------
# Set up for the GNU Scientific Library (GSL).  Note that this setup
# suppports include patterns such as <gsl/gsl_errno.h>.  With this
# format, any other include spec that points to the general include
# directory, such as GEOS, will suffice.  Therefore, an explicit
# include directive is ommitted but provided as an empty reference
# in cases where it may be located elsewhere.  This also goes for the
# library reference.
#---------------------------------------------------------------------------
set(GSLINCDIR "${INCLUDE_DIR}")
set(GSLLIBDIR "${LIB_DIR}")
set(GSLLIB    "-lgsl -lgslcblas")

#---------------------------------------------------------------------------
# Set up for X11
#---------------------------------------------------------------------------
set(X11INCDIR)
set(X11LIBDIR)
if(NOT APPLE)
  set(X11LIB "-lX11") # Must install package libX11-dev
else()
  set(X11LIB ) # Don't use on OSX
endif()


#---------------------------------------------------------------------------
# Set up for GMM
#---------------------------------------------------------------------------
set(GMMINCDIR ${INCLUDE_DIR}/gmm  ${INCLUDE_DIR}/gmm/gmm-5.0  ${INCLUDE_DIR}/gmm/gmm-5.0/gmm)
set(GMMLIBDIR)
set(GMMLIB)

set(ISISCPPFLAGS ${ISISCPPFLAGS} -DGMM_USES_SUPERLU)

#---------------------------------------------------------------------------
# Set up for SuperLU
#---------------------------------------------------------------------------
set(SUPERLUINCDIR ${INCLUDE_DIR}/superlu  ${INCLUDE_DIR}/superlu/superlu4.3)
set(SUPERLULIBDIR "${LIB_DIR}")
if(APPLE)
  set(SUPERLULIB    -lsuperlu_4.3) # TODO: blas is missing, do we need gfortran?
else()
  set(SUPERLULIB    -lsuperlu_4.3 -lblas -lgfortran) # Must install packages libblas-dev and gfortran
endif()

#---------------------------------------------------------------------------
# Set up for Google Protocol Buffers (ProtoBuf)
#---------------------------------------------------------------------------
set(PROTOBUFINCDIR ${INCLUDE_DIR}/google/  ${INCLUDE_DIR}/google-protobuf/protobuf2.6.1)
set(PROTOBUFLIBDIR "${LIB_DIR}")
set(PROTOBUFLIB    "-lprotobuf")
set(PROTOC         "${BIN_DIR}/protoc")

verify_file_exists(${PROTOC})

#---------------------------------------------------------------------------
# Set up for kakadu
# The Kakadu library is proprietary. The source files cannot be distributed
# with ISIS3. If you need to rebuild ISIS3 on your system, then you will
# need to modify the lines below that pertain to the location of the
# header files and library on your system. The compilation flag, ENABLEJP2K,
# should be set to true if you are building with the Kakadu library and
# you want to use the JPEG2000 specific code in the ISIS3 system. Otherwise,
# set the ENABLEJP2K flag to false.
#
#  Added abililty to automatically detect the existance of the Kakadu include
#  directory.  One can set the environment variable JP2KFLAG with a 1 or 0
#  depending upon need.  Developers can define appropriate enviroment variables
#  for the complete JP2K environment.  Just redefine them based upon the usage
#  below (i.e., be sure to add -I, -L and -l to the variables for KAKADUINCDIR,
#  KAKADULIBDIR and KAKADULIB, respectively).
#---------------------------------------------------------------------------
set(KAKADUINCDIR "${INCLUDE_DIR}/kakadu/v6_3-00967N")
set(KAKADULIBDIR "${LIB_DIR}")
set(KAKADULIB    "-lkdu_a63R")

# Detect if Kakadu library is available
set(JP2KFLAG "0")
if(EXISTS "${KAKADUINCDIR}")
  set(JP2KFLAG "1")
endif()

set(ISISCPPFLAGS ${ISISCPPFLAGS} "-DENABLEJP2K=${JP2KFLAG}")

#---------------------------------------------------------------------------
# Set up for BOOST
#---------------------------------------------------------------------------
set(BOOSTINCDIR ${INCLUDE_DIR}/boost  ${INCLUDE_DIR}/boost/boost1.59.0)
#set(BOOSTLIBDIR ${LIB_DIR})
set(BOOSTLIB    "")
#BOOSTLIB    = 
#BOOSTLIBDIR = -L$(ISIS3LOCAL)/lib
#BOOSTLIB    = -lboost_date_time -lboost_filesystem -lboost_graph -lboost_math_c99f
#              -lboost_math_c99l -lboost_math_c99 -lboost_math_tr1f -lboost_math_tr1l
#              -lboost_math_tr1 -lboost_prg_exec_monitor -lboost_program_options
#              -lboost_regex -lboost_serialization -lboost_signals -lboost_system
#              -lboost_thread -lboost_unit_test_framework -lboost_wave -lboost_wserialization

#---------------------------------------------------------------------------
# Set up for Cholmod libraries 
#---------------------------------------------------------------------------
set(CHOLMODINCDIR "${INCLUDE_DIR}/SuiteSparse;${INCLUDE_DIR}/SuiteSparse/SuiteSparse4.4.5/SuiteSparse")
set(CHOLMODLIBDIR "${LIB_DIR}")
set(CHOLMODLIB    -lcholmod -lamd -lcamd -lccolamd -lcolamd -lsuitesparseconfig)
set(CHOLMODLIBFILES libcolamd${SO} libccolamd${SO} libamd${SO} libcamd${SO} libcholmod${SO} libsuitesparseconfig${SO})
if(NOT APPLE)
  set(CHOLMODLIB ${CHOLMODLIB} -llapack)
  set(CHOLMODLIBFILES ${CHOLMODLIBFILES} liblapack${SO})
endif()

#---------------------------------------------------------------------------
# Set up for HDF5 libraries 
#---------------------------------------------------------------------------
set(HDF5INCDIR "${INCLUDE_DIR}/hdf5")
set(HDF5LIBDIR "${LIB_DIR}")
set(HDF5LIB    -lhdf5 -lhdf5_hl -lhdf5_cpp -lhdf5_hl_cpp)

#---------------------------------------------------------------------------
# Set up for OpenCV libraries 
#
# Add the following line to your app's Makefile (see the NN notes)
# $(OPENCVLIBS)
#---------------------------------------------------------------------------
set(OPENCVINCDIR "${INCLUDE_DIR}")
set(OPENCVLIBDIR "${LIB_DIR}")
#set(OPENCVLIB     -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d
#                  -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc
#                  -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect
#                  -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts
#                  -lopencv_video -lopencv_videostab)
set(OPENCVLIB     -lopencv_calib3d -lopencv_core -lopencv_features2d -lopencv_xfeatures2d
                  -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs 
                  -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_stitching 
                  -lopencv_superres  -lopencv_video -lopencv_videostab)

# Missing the following required OpenCV libraries:
#    libavcodec.so.54, libavformat.so.54, libavutil.so.52, libswscale.so.2
# Installed with apt-get libavcodec-dev, libswscale-dev, libavformat-dev

#---------------------------------------------------------------------------
# Set up for Natural Neigbor Library (NN)
#
# * Note that NNINCDIR is not added to ALLINCDIRS in isismake.os
# * and NNLIB is not added to ALLLIBDIRS in isismake.os
#
# For now, if you want to use this library, modify your app's Makefile. 
# Add an empty line after the last line in the Makefile, then add
# $(NNLIB)
# on a new line.
#---------------------------------------------------------------------------
set(NNINCDIR "${INCLUDE_DIR}/nn")
set(NNLIBDIR ${LIB_DIR})
set(NNLIB    "-lnn")


#---------------------------------------------------------------------------
#  Define the third party distribution libraries (patterns)
#---------------------------------------------------------------------------

#  Libraries
set(THIRDPARTYLIBS)

# Normal libraries
foreach(lib ${CHOLMODLIBFILES})
  set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${CHOLMODLIBDIR}/${lib})
endforeach()

# Wildcard library list

set(wildcardLibraries libqwt${SO}* libprotobuf${SO}* libprotobuf.*${SO}  libgeos-*${SO} libgeos_c${SO}* libdsk${SO}* libcspice${SO}* libsuperlu*${SO} libxerces-c*${SO}* libgeotiff*${SO}* libtiff*${SO}* libgsl*${SO}* libkdu_a63R${SO}* libhdf5${SO}* libhdf5_hl${SO}* libhdf5_cpp${SO}* libhdf5_hl_cpp${SO}* libopencv_*${SO}* libtbb${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${LIB_DIR}/libcwd_r${SO}*)

# For each item in this list, expand the wildcard to get the actual library list.
foreach(wildcardLib ${wildcardLibraries})
  file(GLOB expandedLibs ${LIB_DIR}/${wildcardLib})
  #message("wildcardLib = ${wildcardLib}")
  #message("expandedLibs = ${expandedLibs}")
  set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${expandedLibs})
endforeach()

# Add all the OpenCV libraries
# These and some other libs are missing from the 3rd party folder:
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavcodec${SO}*))
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavformat${SO}*))
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavutil${SO}*))



set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${QT_DYNAMIC_LIBS})

# TODO: Check on these
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} $(ISIS3SYSLIB)/libblas*${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} $(ISIS3ALTSYSLIB)/libgfortran${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${ISIS3SYSLIB}/libicuuc${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${ISIS3SYSLIB}/libicudata${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${LIB_DIR}/libpq${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${ISIS3SYSLIB}/libmysqlclient_r${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${ISIS3SYSLIB}/libssl${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${ISIS3SYSLIB}/libcrypto${SO}*)
#set(THIRDPARTYLIBS ${THIRDPARTYLIBS} /lib64/libreadline${SO}*)

# Plugins
file(GLOB_RECURSE THIRDPARTYPLUGINS "${PLUGIN_DIR}/*${SO}")
file(GLOB THIRDPARTYPLUGINFOLDERS "${PLUGIN_DIR}/*")

#message("third party libs = ${THIRDPARTYLIBS}")
#message("third party plugins = ${THIRDPARTYPLUGINS}")
#message("third party plugins folders = ${THIRDPARTYPLUGINFOLDERS}")


#---------------------------------------------------------------------------
# Consolidate information
#---------------------------------------------------------------------------

set(ALLINCDIRS  ${XTRAINCDIRS}
                ${ISISINCDIR}
                ${CWDINCDIR}
                ${QTINCDIR}
                ${QWTINCDIR}
                ${XERCESINCDIR}
                ${GEOTIFFINCDIR}
                ${TIFFINCDIR}
                ${NAIFINCDIR}
                ${TNTINCDIR}
                ${JAMAINCDIR}
                ${GEOSINCDIR}
                ${GSLINCDIR}
                ${GMMINCDIR}
                ${PROTOBUFINCDIR}
                ${BOOSTINCDIR}
                ${CHOLMODINCDIR}
                ${HDF5INCDIR}
                ${SUPERLUINCDIR}
                ${OPENCVINCDIR}
                ${NNINCDIR}
                ${DEFAULTINCDIR}
                ${GMMINCDIR})

set(ALLLIBDIRS  ${XTRALIBDIRS}
                ${ISISLIBDIR}
                ${QTLIBDIR}
                ${QWTLIBDIR}
                ${XERCESLIBDIR}
                ${GEOTIFFLIBDIR}
                ${TIFFLIBDIR}
                ${NAIFLIBDIR}
                ${TNTLIBDIR}
                ${JAMALIBDIR}
                ${GEOSLIBDIR}
                ${GSLLIBDIR}
                ${GMMLIBDIR}
                ${PROTOBUFLIBDIR}
                ${BOOSTLIBDIR}
                ${CHOLMODLIBDIR}
                ${HDF5LIBDIR}
                ${SUPERLULIBDIR}
                ${GMMLIBDIR})

set(ALLLIBS   ${ISISLIB}
              ${ISISSYSLIBS}
              ${XTRALIBS}
              ${QTLIB}
              ${QWTLIB}
              ${XERCESLIB}
              ${GEOTIFFLIB}
              ${TIFFLIB}
              ${NAIFLIB}
              ${TNTLIB}
              ${JAMALIB}
              ${GEOSLIB}
              ${GSLLIB}
              ${X11LIB}
              ${GMMLIB}
              ${PROTOBUFLIB}
              ${BOOSTLIB}
              ${CHOLMODLIB}
              ${HDF5LIB}
              ${SUPERLULIB}
              ${GMMLIB})
#ifeq ($(findstring STATIC, $(MODE)),STATIC)
#  ALLLIBS = $(ISISSTATIC) $(ISISLIB) $(ISISDYNAMIC)
#endif

# Only include Kakadu if it is available
if(${JP2KFLAG} EQUAL "1")
  set(ALLINCDIRS ${ALLINCDIRS} ${KAKADUINCDIR})
  set(ALLLIBDIRS ${ALLLIBDIRS} ${KAKADULIBDIR})
  set(ALLLIBS    ${ALLLIBSS}   ${KAKADULIB}   )
endif()

#message(All libs = "${ALLLIBS}")


