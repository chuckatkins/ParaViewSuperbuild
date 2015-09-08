if (APPLE)
  message(FATAL_ERROR "ABORT")
endif()

if(BUILD_SHARED_LIBS)
  set(shared_args -DBUILD_SHARED=ON -DBUILD_STATIC=OFF)
else()
  set(shared_args -DBUILD_SHARED=OFF -DBUILD_STATIC=ON
    -DWITH_STATIC_DEPENDENCIES=ON
  )
endif()

add_external_project_or_use_system(python
  DEPENDS bzip2 zlib png
  CMAKE_ARGS
    ${shared_args}
    ${python_extra_args} # Possibly -DWITH_STATIC_RUNTIME
    -DPY_VERSION_PATCH=10
    -DBUILD_EXTENSIONS_AS_BUILTIN=ON

    # OpenSSL libcrypt create numerous static dependency problems on
    # various platforms and since we're not using those modules in ParaView
    # then it makes sense to just disable them
    -DUSE_SYSTEM_OpenSSL=OFF
    -DHAVE_LIBCRYPT=IGNORE

    # The curses_panel extension doesn't build properly on numerous HPC
    # environments so again, we just disable it since we don't actually use it.
    -DENABLE_CURSES_PANEL=OFF
  )

set(pv_python_executable "${install_location}/bin/python"
  CACHE INTERNAL "" FORCE)
set(pv_python_include_dir "${install_location}/include/python2.7"
  CACHE INTERNAL "" FORCE)

add_extra_cmake_args(
  -DVTK_PYTHON_VERSION=2.7
)
