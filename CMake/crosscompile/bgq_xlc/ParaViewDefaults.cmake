message(WARNING "Have not successfully compiled on BlueGeneQ with XLC compiler.")
message(WARNING "Expect a link failure (out of TOC space) after 100% compilation.")

set(64bit_build TRUE)
set(cflags "-qminimaltoc")
set(cxxflags "-qminimaltoc")

#
set(PARAVIEW_OPTIONS "")
list(APPEND PARAVIEW_OPTIONS "-DBUILD_SHARED_LIBS:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DBUILD_TESTING:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_QT_GUI:BOOL=OFF")
#
list(APPEND PARAVIEW_OPTIONS "-DENABLE_MPI4PY:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DVTK_USE_SYSTEM_MPI4PY:BOOL=ON")
#
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_USE_MPI:BOOL=ON")
list(APPEND PARAVIEW_OPTIONS "-DMPIEXEC:FILEPATH=cobalt-mpirun")
#
list(APPEND PARAVIEW_OPTIONS "-DVTK_USE_SYSTEM_HDF5:BOOL=0")
#list(APPEND PARAVIEW_OPTIONS "-DHDF5_FOUND:BOOL=1")
#list(APPEND PARAVIEW_OPTIONS "-DHDF5_LIBRARIES:STRING=/soft/libraries/hdf5/current/cnk-xl/current/lib/libhdf5.a")
#list(APPEND PARAVIEW_OPTIONS "-DHDF5_INCLUDE_DIRS:STRING=/soft/libraries/hdf5/current/cnk-xl/current/include${ep_list_separator}/bgsys/drivers/V1R2M0/ppc64/comm/xl/include")
#
list(APPEND PARAVIEW_OPTIONS "-DVTK_USE_SYSTEM_ZLIB:BOOL=1")
list(APPEND PARAVIEW_OPTIONS "-DZLIB_LIBRARY:FILEPATH=/soft/libraries/alcf/current/xl/ZLIB/lib/libz.a")
list(APPEND PARAVIEW_OPTIONS "-DZLIB_INCLUDE_DIR:PATH=/soft/libraries/alcf/current/xl/ZLIB/include")
#
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_ENABLE_FFMPEG:BOOL=OFF")
#
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_USE_VISITBRIDGE:BOOL=ON")
list(APPEND PARAVIEW_OPTIONS "-DVISIT_BUILD_READER_CGNS:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DVISIT_BUILD_READER_Silo:BOOL=OFF")
#
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_ENABLE_WEB:BOOL=OFF")
#
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_AdiosReader:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_AnalyzeNIfTIIO:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_ArrowGlyph:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_CoProcessingScriptGenerator:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_EyeDomeLighting:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_ForceTime:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_GMVReader:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_H5PartReader:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_MantaView:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_Moments:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_Nektar:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_NonOrthogonalSource:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_PacMan:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_PointSprite:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_PrismPlugin:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_QuadView:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_SLACTools:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_SciberQuestToolKit:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_SierraPlotTools:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_SurfaceLIC:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_UncertaintyRendering:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_VaporPlugin:BOOL=OFF")
list(APPEND PARAVIEW_OPTIONS "-DPARAVIEW_BUILD_PLUGIN_pvblot:BOOL=OFF")
