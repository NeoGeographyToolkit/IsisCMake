#===============================================================================
# High level script to handle all required 3rd party dependencies
# - All of them are expected to be in the 3rdParty folder, this script does not
#   go looking for them if they are not?
#===============================================================================

# Specify top level directories

set(thirdPartyDir "${CMAKE_SOURCE_DIR}/3rdParty")

set(INCLUDE_DIR "${thirdPartyDir}/include")
set(LIB_DIR     "${thirdPartyDir}/lib")
set(PLUGIN_DIR  "${thirdPartyDir}/plugins")
set(BIN_DIR     "${thirdPartyDir}/bin")

# The common method of putting a version in a library name differs
#  between OSX and Linux.
if(APPLE)
  set(end "*.dylib")
else()
  set(end ".so*")
endif()

set(XALAN   "${BIN_DIR}/Xalan")
#set(LATEX   "${BIN_DIR}/latex") # MISSING
#set(DOXYGEN "${BIN_DIR}/doxygen") # MISSING
set(DOXYGEN "/home/smcmich1/doxygen-1.8.8/bin/doxygen") # TODO: 
set(LATEX   "/usr/bin/latex") # MISSING
# Also need the DOT tool for doxygen.

verify_file_exists(${XALAN})
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

# One set of libs is for link statements, the other is for installation.

if(APPLE)

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

else() # Linux

  set(QTLIBDIR ${LIB_DIR})

  set(QTLIB    -lQt5Core -lQt5Concurrent -lQt5XmlPatterns -lQt5Xml -lQt5Network -lQt5Sql -lQt5Gui -lQt5PrintSupport -lQt5Positioning -lQt5Qml -lQt5Quick -lQt5Sensors -lQt5Svg -lQt5Test -lQt5OpenGL -lQt5Widgets -lQt5Multimedia -lQt5MultimediaWidgets -lQt5WebChannel -lQt5WebEngine -lQt5WebEngineWidgets -lQt5DBus)

  set(QT_DYNAMIC_LIBS)
  set(QT_DYNAMIC_IN  ${QTLIBDIR}/libQt5Concurrent.so
                   ${QTLIBDIR}/libQt5Core.so
                   ${QTLIBDIR}/libQt5DBus.so
                   ${QTLIBDIR}/libQt5Gui.so
                   ${QTLIBDIR}/libQt5Multimedia.so
                   ${QTLIBDIR}/libQt5MultimediaWidgets.so
                   ${QTLIBDIR}/libQt5Network.so
                   ${QTLIBDIR}/libQt5OpenGL.so
                   ${QTLIBDIR}/libQt5Positioning.so
                   ${QTLIBDIR}/libQt5PrintSupport.so
                   ${QTLIBDIR}/libQt5Qml.so
                   ${QTLIBDIR}/libQt5Quick.so
                   ${QTLIBDIR}/libQt5Sensors.so
                   ${QTLIBDIR}/libQt5Sql.so
                   ${QTLIBDIR}/libQt5Svg.so
                   ${QTLIBDIR}/libQt5Test.so
                   ${QTLIBDIR}/libQt5WebChannel.so
                   ${QTLIBDIR}/libQt5WebEngineCore.so
                   ${QTLIBDIR}/libQt5WebEngine.so
                   ${QTLIBDIR}/libQt5WebEngineWidgets.so
                   ${QTLIBDIR}/libQt5Widgets.so
                   ${QTLIBDIR}/libQt5XcbQpa.so
                   ${QTLIBDIR}/libQt5Xml.so
                   ${QTLIBDIR}/libQt5XmlPatterns.so)
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

  set(QWT_DYNAMIC_LIBS ${QWTLIBDIR}/qwt.framework)

else()
  
  set(QWTLIBDIR "${LIB_DIR}")
  set(QWTLIB    "-lqwt")
  set(QWT_DYNAMIC_LIBS ${LIB_DIR}/libqwt.so ${LIB_DIR}/libqwt.so.6 ${LIB_DIR}/libqwt.so.6.1 ${LIB_DIR}/libqwt.so.6.12)
endif()


#---------------------------------------------------------------------------
# Set up for Xerces 
#---------------------------------------------------------------------------
set(XERCESINCDIR ${INCLUDE_DIR}/xercesc ${INCLUDE_DIR}/xercesc/xercesc-3.1.2)
set(XERCESLIBDIR "${LIB_DIR}")
set(XERCESLIB    "-lxerces-c")
set(XERCES_DYNAMIC_LIBS ${XERCESLIBDIR}/libxerces-c${end})

#---------------------------------------------------------------------------
# Set up for geotiff 
#---------------------------------------------------------------------------
set(GEOTIFFINCDIR "${INCLUDE_DIR}/geotiff")
set(GEOTIFFLIBDIR "${LIB_DIR}")
set(GEOTIFFLIB    "-lgeotiff")
set(GEOTIFF_DYNAMIC_LIBS ${GEOTIFFLIBDIR}/libgeotiff${end})

#---------------------------------------------------------------------------
# Set up for Tiff 
#---------------------------------------------------------------------------
set(TIFFINCDIR "${INCLUDE_DIR}/tiff/tiff-4.0.5")
set(TIFFLIBDIR "${LIB_DIR}")
set(TIFFLIB    "-ltiff")
set(TIFF_DYNAMIC_LIBS ${TIFFLIBDIR}/libtiff${end})

#---------------------------------------------------------------------------
# Set up for naif dsk and cspice libraries
#---------------------------------------------------------------------------
set(NAIFINCDIR "${INCLUDE_DIR}/naif")
set(NAIFLIBDIR "${LIB_DIR}")
if(APPLE)
  set(NAIFLIB    "-ldsklib -lcspice")
  set(NAIF_DYNAMIC_LIBS ${NAIFLIBDIR}/libdsklib${end} ${NAIFLIBDIR}/libcspice${end})
else()
  set(NAIFLIB    "-ldsk -lcspice")
  set(NAIF_DYNAMIC_LIBS ${NAIFLIBDIR}/libdsk${end} ${NAIFLIBDIR}/libcspice${end})
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
set(GEOS_DYNAMIC_LIBS ${GEOSLIBDIR}/libgeos${end})

#---------------------------------------------------------------------------
# Set up for the GNU Scientific Library (GSL).  
#---------------------------------------------------------------------------
set(GSLINCDIR "${INCLUDE_DIR}")
set(GSLLIBDIR "${LIB_DIR}")
set(GSLLIB    "-lgsl -lgslcblas")
set(GSL_DYNAMIC_LIBS ${GSLLIBDIR}/libgsl${end} ${GSLLIBDIR}/libgslcblas${end})

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

set(thirdPartyCppFlags ${thirdPartyCppFlags} -DGMM_USES_SUPERLU)

#---------------------------------------------------------------------------
# Set up for SuperLU
#---------------------------------------------------------------------------
set(SUPERLUINCDIR ${INCLUDE_DIR}/superlu  ${INCLUDE_DIR}/superlu/superlu4.3)
set(SUPERLULIBDIR "${LIB_DIR}")
if(APPLE)
  set(SUPERLULIB    -lsuperlu_4.3)
  set(SUPERLU_DYNAMIC_LIBS ${SUPERLULIBDIR}/libsuperlu.dylib ${SUPERLULIBDIR}/libsuperlu_*.dylib)
else()
  set(SUPERLULIB    -lsuperlu_4.3 -lblas -lgfortran) # Must install packages libblas-dev and gfortran
  set(SUPERLU_DYNAMIC_LIBS ${SUPERLULIBDIR}/libsuperlu_*.so ${SUPERLULIBDIR}/libblas.so.* ${SUPERLULIBDIR}/libgfortran.so.*)
endif()

#---------------------------------------------------------------------------
# Set up for Google Protocol Buffers (ProtoBuf)
#---------------------------------------------------------------------------
set(PROTOBUFINCDIR ${INCLUDE_DIR}/google/  ${INCLUDE_DIR}/google-protobuf/protobuf2.6.1)
set(PROTOBUFLIBDIR "${LIB_DIR}")
set(PROTOBUFLIB    "-lprotobuf")
set(PROTOC         "${BIN_DIR}/protoc")
set(PROTOBUF_DYNAMIC_LIBS ${PROTOBUFLIBDIR}/libproto${end})

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
#---------------------------------------------------------------------------
set(KAKADUINCDIR  "${INCLUDE_DIR}/kakadu/v6_3-00967N")
set(KAKADULIBDIR  "${LIB_DIR}")
set(KAKADULIB     "-lkdu_a63R")

# Detect if Kakadu library is available
set(JP2KFLAG "0")
set(KAKADU_DYNAMIC_LIBS)
if((EXISTS "${KAKADUINCDIR}") AND (EXISTS "${KAKADULIBFILE}"))
  set(JP2KFLAG "1")
  set(KAKADU_DYNAMIC_LIBS ${KAKADULIBDIR}/libkdu_a63R${end})
endif()

set(thirdPartyCppFlags ${thirdPartyCppFlags} "-DENABLEJP2K=${JP2KFLAG}")

#---------------------------------------------------------------------------
# Set up for BOOST
#---------------------------------------------------------------------------
set(BOOSTINCDIR ${INCLUDE_DIR}/boost  ${INCLUDE_DIR}/boost/boost1.59.0)
set(BOOSTLIB)


#---------------------------------------------------------------------------
# Set up for Cholmod libraries 
#---------------------------------------------------------------------------
set(CHOLMODINCDIR "${INCLUDE_DIR}/SuiteSparse;${INCLUDE_DIR}/SuiteSparse/SuiteSparse4.4.5/SuiteSparse")
set(CHOLMODLIBDIR "${LIB_DIR}")
set(CHOLMODLIB    -lcholmod -lamd -lcamd -lccolamd -lcolamd -lsuitesparseconfig)
set(CHOLMOD_DYNAMIC_LIBS ${CHOLMODLIBDIR}/libcolamd${end}  ${CHOLMODLIBDIR}/libccolamd${end} 
                         ${CHOLMODLIBDIR}/libamd${end}     ${CHOLMODLIBDIR}/libcamd${end} 
                         ${CHOLMODLIBDIR}/libcholmod${end} ${CHOLMODLIBDIR}/libsuitesparseconfig${end})
if(NOT APPLE)
  set(CHOLMOD_DYNAMIC_LIBS ${CHOLMOD_DYNAMIC_LIBS} ${CHOLMODLIBDIR}/liblapack.so)
  set(CHOLMODLIB ${CHOLMODLIB} -llapack)
endif()

#---------------------------------------------------------------------------
# Set up for HDF5 libraries 
#---------------------------------------------------------------------------
set(HDF5INCDIR "${INCLUDE_DIR}/hdf5")
set(HDF5LIBDIR "${LIB_DIR}")
set(HDF5LIB    -lhdf5 -lhdf5_hl -lhdf5_cpp -lhdf5_hl_cpp)
set(HDF5_DYNAMIC_LIBS ${HDF5LIBDIR}/libhdf5${end}     ${HDF5LIBDIR}/libhdf5_hl${end} 
                      ${HDF5LIBDIR}/libhdf5_cpp${end} ${HDF5LIBDIR}/libhdf5_hl_cpp${end})

#---------------------------------------------------------------------------
# Set up for OpenCV libraries 
#---------------------------------------------------------------------------
set(OPENCVINCDIR "${INCLUDE_DIR}")
set(OPENCVLIBDIR "${LIB_DIR}")
set(OPENCVLIB     -lopencv_calib3d -lopencv_core -lopencv_features2d -lopencv_xfeatures2d
                  -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs 
                  -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_stitching 
                  -lopencv_superres  -lopencv_video -lopencv_videostab)
set(OPENCV_DYNAMIC_LIBS ${OPENCVLIBDIR}/libopencv_${end} ${OPENCVLIBDIR}/libavcodec${end} 
                        ${OPENCVLIBDIR}/libavformat${end} ${OPENCVLIBDIR}/libavutil${end})

# Missing the following required OpenCV libraries:
#    libavcodec.so.54, libavformat.so.54, libavutil.so.52, libswscale.so.2
# Installed with apt-get libavcodec-dev, libswscale-dev, libavformat-dev

#---------------------------------------------------------------------------
# Set up for Natural Neigbor Library (NN)
#---------------------------------------------------------------------------
set(NNINCDIR "${INCLUDE_DIR}/nn")
set(NNLIBDIR ${LIB_DIR})
set(NNLIB    "-lnn")


#---------------------------------------------------------------------------
#  Define the third party distribution libraries (patterns)
#---------------------------------------------------------------------------

# On OSX we need to include a LOT of extra libraries!
set(EXTRA_DYNAMIC_LIBS)
if(APPLE)

  set(EXTRALIBDIR ${LIB_DIR})
  set(temp
    # QT dependencies
    libpcre16*.dylib
    libgthread-*.dylib
    libpcre.*dylib
    libharfbuzz*.dylib
    libgraphite2.*dylib
    libleveldb*.dylib*
    libsnappy.*dylib
    libwebp*.dylib
    libdbus*.dylib
    libiconv*.dylib
    liblzma*.dylib
    libz*.dylib
    libssl*.dylib
    libcrypto*.dylib
    libpng*.dylib
    libjpeg.*dylib
    libmng.*dylib
    liblcms2.*dylib
    libsqlite3.*dylib
    postgresql*/libpq.*dylib
    mysql56/mysql/libmysqlclient*.dylib
    libiodbc*.dylib
    # OpenCV dependancies
    libtbb*.dylib
    libjasper*.dylib
    libImath*.dylib
    libIlmImf*.dylib
    libIex*.dylib
    libHalf*.dylib
    libIlmThread*.dylib
    libswscale*.dylib
    # Secondary requirements to all OpenCV dependancies
    libSDL-1*.dylib
    libnettle*.dylib
    libhogweed*.dylib
    libgmp*.dylib
    libxvidcore*.dylib
    libx264*.dylib
    libvorbisenc*.dylib
    libvorbis*.dylib
    libogg*.dylib
    libtheoraenc*.dylib
    libtheoradec*.dylib
    libspeex*.dylib
    libschroedinger-1*.dylib
    libopus*.dylib
    libopenjpeg*.dylib
    libmp3lame*.dylib
    libmodplug*.dylib
    libfreetype*.dylib
    libbluray*.dylib
    libass*.dylib
    libgnutls*.dylib
    libbz2*.dylib
    libXrandr*.dylib
    libXext*.dylib
    libXrender*.dylib
    libX11*.dylib
    libxcb*.dylib
    libXau*.dylib
    libXdmcp*.dylib
    liborc-0*.dylib
    libxml2*.dylib
    libfribidi*.dylib
    libfontconfig*.dylib
    libexpat*.dylib
    libintl*.dylib
    libglib-*.dylib
    libp11-kit*.dylib
    libffi*.dylib
    # OpenCV3 dependencies
    libavresample*.dylib
    libxcb-shm*.dylib
    libsoxr*.dylib
    libopenjp2*.dylib
    libOpenNI*.dylib
    libswresample*.dylib
    libidn*.dylib
    libtasn1*.dylib
    libusb*.dylib
    # libxerces-c depends on these libraries
    libicui18n*.dylib
    libicuuc*.dylib
    libicudata*.dylib
    # libgeotiff depends on these libraries
    libproj*.dylib)

  foreach(lib ${temp})
    set(EXTRA_DYNAMIC_LIBS ${EXTRA_DYNAMIC_LIBS} ${EXTRALIBDIR}/${lib})
  endforeach()
endif()

#message("EXTRA_DYNAMIC_LIBS = ${EXTRA_DYNAMIC_LIBS}")

#  Libraries
set(THIRDPARTYLIBS)

set(RAW_DYNAMIC_LIBS ${QT_DYNAMIC_LIBS}
                     ${QWT_DYNAMIC_LIBS}
                     ${XERCES_DYNAMIC_LIBS}
                     ${GEOTIFF_DYNAMIC_LIBS}
                     ${HDF5_DYNAMIC_LIBS}
                     ${TIFF_DYNAMIC_LIBS}
                     ${NAIF_DYNAMIC_LIBS}
                     ${GEOS_DYNAMIC_LIBS}
                     ${GSL_DYNAMIC_LIBS}
                     ${SUPERLU_DYNAMIC_LIBS}
                     ${PROTOBUF_DYNAMIC_LIBS}
                     ${KAKADU_DYNAMIC_LIBS} # Empty if not available
                     ${CHOLMOD_DYNAMIC_LIBS}
                     ${OPENCV_DYNAMIC_LIBS}
                     ${EXTRA_DYNAMIC_LIBS})

#message("THIRDPARTYLIBS = ${RAW_DYNAMIC_LIBS}")


# For each item in this list, expand the wildcard to get the actual library list.
foreach(lib ${RAW_DYNAMIC_LIBS})
  
  string(FIND "${lib}" "*" position)
  if(${position} EQUAL -1)
    # No wildcard, just add it.
    set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${lib})
  else()
    # Expand wildcard, then add.
    file(GLOB expandedLibs ${lib})
    set(THIRDPARTYLIBS ${THIRDPARTYLIBS} ${expandedLibs})
  endif() 
endforeach()

#message("THIRDPARTYLIBS = ${THIRDPARTYLIBS}")

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


