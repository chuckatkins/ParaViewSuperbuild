if(BUILD_SHARED_LIBS)
  set(shared_args --enable-shared --disable-static)
else()
  set(shared_args --disable-shared --enable-static)
endif()
add_external_project(
  silo
  DEPENDS zlib hdf5
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND <SOURCE_DIR>/configure
                    --prefix=<INSTALL_DIR>
                    ${shared_args}
                    --enable-fortran=no
                    --enable-browser=no
                    --enable-silex=no
                    --with-szlib=<INSTALL_DIR>
                    --with-hdf5=<INSTALL_DIR>/include,<INSTALL_DIR>/lib
)
