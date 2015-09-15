if(BUILD_SHARED_LIBS)
  set(png_shared_args -DPNG_SHARED:BOOL=ON -DPNG_STATIC:BOOL=OFF)
else()
  set(png_shared_args -DPNG_SHARED:BOOL=OFF -DPNG_STATIC:BOOL=ON)
endif()

add_external_project_or_use_system(png
  DEPENDS zlib

  CMAKE_ARGS
    ${png_shared_args}
    -DPNG_TESTS:BOOL=OFF
    # VTK uses API that gets hidden when PNG_NO_STDIO is TRUE (default).
    -DPNG_NO_STDIO:BOOL=OFF
  )
