# Tarballs needing to be downloaded:
# boost
# numpy
# osmesa
# paraview
# python
# visitbridge

set(CMAKE_BUILD_TYPE  Release CACHE STRING "")

if("$ENV{CRAYPE_LINK_TYPE}" STREQUAL "dynamic")
  set(BUILD_SHARED_LIBS ON CACHE BOOL "")
  set(LIB_EXT .so)
else()
  set(WITH_STATIC_DEPENDENCIES ON CACHE BOOL "")
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "")
  set(LIB_EXT .a)
  set(python_extra_args -DWITH_STATIC_RUNTIME=ON CACHE STRING "")
endif()

set(ENABLE_boost       ON CACHE BOOL "")
set(ENABLE_bzip2       ON CACHE BOOL "")
set(ENABLE_hdf5        ON CACHE BOOL "")
set(ENABLE_lapack      ON CACHE BOOL "")
set(ENABLE_libxml2     ON CACHE BOOL "")
set(ENABLE_mpi         ON CACHE BOOL "")
set(ENABLE_numpy       ON CACHE BOOL "")
set(ENABLE_osmesa      ON CACHE BOOL "")
set(ENABLE_paraview    ON CACHE BOOL "")
set(ENABLE_paraviewsdk ON CACHE BOOL "")
set(ENABLE_png         ON CACHE BOOL "")
set(ENABLE_python      ON CACHE BOOL "")
set(ENABLE_visitbridge ON CACHE BOOL "")
set(ENABLE_zlib        ON CACHE BOOL "")

# These will get pulled from the compute node's userland
set(USE_SYSTEM_bzip2    ON CACHE BOOL "")
set(USE_SYSTEM_libxml2  ON CACHE BOOL "")
#set(USE_SYSTEM_png      ON CACHE BOOL "")
set(USE_SYSTEM_zlib     ON CACHE BOOL "")

# This comes form the cray-hdf5 module
set(USE_SYSTEM_hdf5     ON CACHE BOOL "")

# This comes from the cray-libsci module
string(TOLOWER "$ENV{PE_ENV}" PE_low)
set(USE_SYSTEM_lapack   ON CACHE BOOL "")
set(BLAS_LIBRARIES
  "$ENV{CRAY_LIBSCI_PREFIX_DIR}/lib/libsci_${PE_low}${LIB_EXT}"
  CACHE FILEPATH "")
set(LAPACK_LIBRARIES
  "$ENV{CRAY_LIBSCI_PREFIX_DIR}/lib/libsci_${PE_low}${LIB_EXT}"
  CACHE FILEPATH "")

# This comes from the cray-mpich module
set(USE_SYSTEM_mpi      ON CACHE BOOL "")
find_program(MPIEXEC aprun)

# Make sure the final ParaView build uses the whole node
include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  set(PV_MAKE_NCPUS ${N} CACHE STRING "")
else()
  set(PV_MAKE_NCPUS 5 CACHE STRING "")
endif()

# Download location
set(download_location $ENV{HOME}/Code/ParaView/superbuild/downloads
  CACHE PATH "")

set(ParaView_FROM_GIT OFF CACHE BOOL "")
set(ParaView_URL "ParaView-v4.3.1-source.tar.gz" CACHE STRING "")
set(ParaView_URL_MD5 "d03d3ab504037edd21306413dff64293" CACHE STRING "")

