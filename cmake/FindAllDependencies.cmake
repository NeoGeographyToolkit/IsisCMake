#===============================================================================
#        High level script to find all required 3rd party dependencies
#
#===============================================================================


# TODO: Indent all!

set(INCLUDE_DIR "${thirdPartyDir}/include")
set(LIB_DIR     "${thirdPartyDir}/lib")
set(BIN_DIR     "${thirdPartyDir}/bin")

#---------------------------------------------------------------------------
# Set up for Qt
#---------------------------------------------------------------------------
set(qtDir "${thirdPartyDir}/qt/qt5.6.0/")
# Each of the folders in the main QT folder is needed as an include directory
SUBDIRLIST(${qtDir} qtFolders)
set(QTINCDIR ${qtDir})
foreach(f ${qtFolders})
  set(QTINCDIR ${QTINCDIR} ${f}) 
endforeach()

set(QTLIBDIR ${LIB_DIR})
set(QTLIB    "-lQt5Core -lQt5Concurrent -lQt5XmlPatterns -lQt5Xml -lQt5Network -lQt5Sql -lQt5Gui -lQt5PrintSupport -lQt5Positioning -lQt5Qml -lQt5Quick -lQt5Sensors -lQt5Svg -lQt5Test -lQt5OpenGL -lQt5Widgets -lQt5Multimedia -lQt5MultimediaWidgets -lQt5WebChannel -lQt5WebEngine -lQt5WebEngineWidgets -lQt5DBus")

set(QT_DYNAMIC_LIBS)
set(QT_DYNAMIC_IN "${LIB_DIR}/libQt5Concurrent.so \
                   ${LIB_DIR}/libQt5Core.so \
                   ${LIB_DIR}/libQt5DBus.so \
                   ${LIB_DIR}/libQt5Gui.so \
                   ${LIB_DIR}/libQt5Multimedia.so \
                   ${LIB_DIR}/libQt5MultimediaWidgets.so \
                   ${LIB_DIR}/libQt5Network.so \
                   ${LIB_DIR}/libQt5OpenGL.so \
                   ${LIB_DIR}/libQt5Positioning.so \
                   ${LIB_DIR}/libQt5PrintSupport.so \
                   ${LIB_DIR}/libQt5Qml.so \
                   ${LIB_DIR}/libQt5Quick.so \
                   ${LIB_DIR}/libQt5Sensors.so \
                   ${LIB_DIR}/libQt5Sql.so \
                   ${LIB_DIR}/libQt5Svg.so \
                   ${LIB_DIR}/libQt5Test.so \
                   ${LIB_DIR}/libQt5WebChannel.so \
                   ${LIB_DIR}/libQt5WebEngineCore.so \
                   ${LIB_DIR}/libQt5WebEngine.so \
                   ${LIB_DIR}/libQt5WebEngineWidgets.so \
                   ${LIB_DIR}/libQt5Widgets.so \
                   ${LIB_DIR}/libQt5XcbQpa.so \
                   ${LIB_DIR}/libQt5Xml.so \
                   ${LIB_DIR}/libQt5XmlPatterns.so")
foreach(f ${QT_DYNAMIC_IN})
  set(QT_DYNAMIC_LIBS "${QT_DYNAMIC_LIBS} ${f} ${f}.5 ${f}.5.6*[^g]")
endforeach()


# Binary paths
set(UIC "${BIN_DIR}/uic")
set(MOC "${BIN_DIR}/moc")
set(RCC "${BIN_DIR}/rcc")

#---------------------------------------------------------------------------
# Set up for Qwt
#---------------------------------------------------------------------------
set(QWTINCDIR "${INCLUDE_DIR}/qwt")
set(QWTLIBDIR "${LIB_DIR}")
set(QWTLIB    "-lqwt")

#---------------------------------------------------------------------------
# Set up for Xerces 
#---------------------------------------------------------------------------
set(XERCESINCDIR "${INCLUDE_DIR}/xercesc/xercesc-3.1.2")
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
set(NAIFLIB    "-ldsk -lcspice")

#---------------------------------------------------------------------------
# Set up for TNT
#---------------------------------------------------------------------------
set(TNTINCDIR "${INCLUDE_DIR}/tnt/tnt126 ${INCLUDE_DIR}/tnt/tnt126/tnt")
set(TNTLIBDIR)
set(TNTLIB)

#---------------------------------------------------------------------------
# Set up for JAMA
#---------------------------------------------------------------------------
set(JAMAINCDIR "${INCLUDE_DIR}/jama/jama125")
set(JAMALIBDIR)
set(JAMA)

#---------------------------------------------------------------------------
# Set up for GEOS
#---------------------------------------------------------------------------
set(GEOSINCDIR "${INCLUDE_DIR}/geos/geos3.5.0")
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
set(X11LIB    "-lX11")

#---------------------------------------------------------------------------
# Set up for GMM
#---------------------------------------------------------------------------
set(GMINCDIR "${INCLUDE_DIR}/gmm/gmm-5.0  ${INCLUDE_DIR}/gmm/gmm-5.0/gmm")
set(GMMLIBDIR)
set(GMLIB)

#---------------------------------------------------------------------------
# Set up for SuperLU
#---------------------------------------------------------------------------
set(SUPERLUINCDIR "${INCLUDE_DIR}/superlu/superlu4.3")
set(SUPERLULIBDIR "${LIB_DIR}")
set(SUPERLULIB    "-lsuperlu_4.3 -lblas -lgfortran")

#---------------------------------------------------------------------------
# Set up for Google Protocol Buffers (ProtoBuf)
#---------------------------------------------------------------------------
set(PROTOBUFINCDIR "${INCLUDE_DIR}/google-protobuf/protobuf2.6.1")
set(PROTOBUFLIBDIR "${LIB_DIR}")
set(PROTOBUFLIB    "-lprotobuf")
set(PROTOC         "${BIN_DIR}/protoc")

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
if(EXISTS "${KAKADUINCDIR})
  set(JP2KFLAG "1")
endif()

set(ISISCPPFLAGS ${ISISCPPFLAGS} "-DENABLEJP2K=${JP2KFLAG}")

#---------------------------------------------------------------------------
# Set up for BOOST
#---------------------------------------------------------------------------
set(BOOSTINCDIR "${INCLUDE_DIR}/boost/boost1.59.0")
#set(BOOSTLIBDIR ${LIB_DIR})
set(BOOSTLIB    "")
#BOOSTLIB    = 
#BOOSTLIBDIR = -L$(ISIS3LOCAL)/lib
#BOOSTLIB    = -lboost_date_time -lboost_filesystem -lboost_graph -lboost_math_c99f \
#              -lboost_math_c99l -lboost_math_c99 -lboost_math_tr1f -lboost_math_tr1l \
#              -lboost_math_tr1 -lboost_prg_exec_monitor -lboost_program_options \
#              -lboost_regex -lboost_serialization -lboost_signals -lboost_system \
#              -lboost_thread -lboost_unit_test_framework -lboost_wave -lboost_wserialization

#---------------------------------------------------------------------------
# Set up for Cholmod libraries 
#---------------------------------------------------------------------------
set(CHOLMODINCDIR "${INCLUDE_DIR}/SuiteSparse/SuiteSparse4.4.5/SuiteSparse")
set(CHOLMODLIBDIR "${LIB_DIR}")
set(CHOLMODLIB    "-lcholmod -lamd -lcamd -lccolamd -lcolamd -llapack -lsuitesparseconfig")

#---------------------------------------------------------------------------
# Set up for HDF5 libraries 
#---------------------------------------------------------------------------
set(HDF5INCDIR "${INCLUDE_DIR}/hdf5")
set(HDF5LIBDIR "${LIB_DIR}")
set(HDF5LIB    "-lhdf5 -lhdf5_hl -lhdf5_cpp -lhdf5_hl_cpp")

#---------------------------------------------------------------------------
# Set up for OpenCV libraries 
#
# Add the following line to your app's Makefile (see the NN notes)
# $(OPENCVLIBS)
#---------------------------------------------------------------------------
set(OPENCVINCDIR "${INCLUDE_DIR}")
set(OPENCVLIBDIR "${LIB_DIR}")
set(OPENCVLIB    "-lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d \
                  -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc \
                  -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect \
                  -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts \
                  -lopencv_video -lopencv_videostab")

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
set(THIRDPARTYLIBS ${QT_DYNAMIC_LIBS})

set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libqwt.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libprotobuf.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libgeos-*.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libgeos_c.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libdsk.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libcspice.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libcwd_r.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libcolamd.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libccolamd.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libamd.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libcamd.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libcholmod.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libsuperlu*.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libsuitesparseconfig.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/liblapack.so")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "$(ISIS3SYSLIB)/libblas*.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "$(ISIS3ALTSYSLIB)/libgfortran.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libxerces-c*.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libgeotiff*.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libtiff*.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libgsl*.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "${ISIS3SYSLIB}/libicuuc.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "${ISIS3SYSLIB}/libicudata.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libpq.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "${ISIS3SYSLIB}/libmysqlclient_r.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "${ISIS3SYSLIB}/libssl.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "${ISIS3SYSLIB}/libcrypto.so*")
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} "/lib64/libreadline.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libkdu_a63R.so*")

set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libhdf5.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libhdf5_hl.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libhdf5_cpp.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libhdf5_hl_cpp.so*")

# Add all the OpenCV libraries
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libopencv_*.so*")
set(THIRDPARTYLIBS "${THIRDPARTYLIBS} ${LIB_DIR}/libtbb.so*")
# TODO: What is up with these three?
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavcodec.so*))
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavformat.so*))
#set(THIRDPARTYLIBS "${THIRDPARTYLIBS} $(wildcard ${ISIS3ALTSYSLIB}/libavutil.so*))


#  Plugins
set(THIRDPARTYPLUGINS "${ISIS3LOCAL}/plugins/")




#---------------------------------------------------------------------------
# Consolidate information
#---------------------------------------------------------------------------

set(ALLINCDIRS "${XTRAINCDIRS} \
                ${ISISINCDIR} \
                ${CWDINCDIR} \
                ${QTINCDIR} \
                ${QWTINCDIR} \
                ${XERCESINCDIR} \
                ${GEOTIFFINCDIR} \
                ${TIFFINCDIR} \
                ${NAIFINCDIR} \
                ${TNTINCDIR} \
                ${JAMAINCDIR} \
                ${GEOSINCDIR} \
                ${GSLINCDIR} \
                ${GMMINCDIR} \
                ${PROTOBUFINCDIR} \
                ${BOOSTINCDIR} \
                ${CHOLMODINCDIR} \
                ${HDF5INCDIR} \
                ${SUPERLUINCDIR} \
                ${OPENCVINCDIR} \
                ${NNINCDIR} \
                ${DEFAULTINCDIR}")

set(ALLLIBDIRS "${XTRALIBDIRS} \
                ${ISISLIBDIR} \
                ${QTLIBDIR} \
                ${QWTLIBDIR} \
                ${XERCESLIBDIR} \
                ${GEOTIFFLIBDIR} \
                ${TIFFLIBDIR} \
                ${NAIFLIBDIR} \
                ${TNTLIBDIR} \
                ${JAMALIBDIR} \
                ${GEOSLIBDIR} \
                ${GSLLIBDIR} \
                ${GMMLIBDIR} \
                ${PROTOBUFLIBDIR} \
                ${BOOSTLIBDIR} \
                ${CHOLMODLIBDIR} \
                ${HDF5LIBDIR} \
                ${SUPERLULIBDIR}")

set(ALLLIBS  "${ISISLIB} \
              ${ISISSYSLIBS} \
              ${XTRALIBS} \
              ${QTLIB} \
              ${QWTLIB} \
              ${XERCESLIB} \
              ${GEOTIFFLIB} \
              ${TIFFLIB} \
              ${NAIFLIB} \
              ${TNTLIB} \
              ${JAMALIB} \
              ${GEOSLIB} \
              ${GSLLIB} \
              ${X11LIB} \
              ${GMMLIB} \
              ${PROTOBUFLIB} \
              ${BOOSTLIB} \
              ${CHOLMODLIB} \
              ${HDF5LIB} \
              ${SUPERLULIB}")
#ifeq ($(findstring STATIC, $(MODE)),STATIC)
#  ALLLIBS = $(ISISSTATIC) $(ISISLIB) $(ISISDYNAMIC)
#endif

# Only include Kakadu if it is available
if(${JP2KFLAG} EQUAL "1")
  set(ALLINCDIRS "${ALLINCDIRS} ${KAKADUINCDIR}")
  set(ALLLIBDIRS "${ALLLIBDIRS} ${KAKADULIBDIR}")
  set(ALLLIBS    "${ALLLIBSS}   ${KAKADULIB}"   )
endif()


