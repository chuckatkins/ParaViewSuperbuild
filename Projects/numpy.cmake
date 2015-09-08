set (_install_location "<INSTALL_DIR>")
if (WIN32)
  # numpy build has issues with paths containing "C:". So we set the prefix as a
  # relative path.
  set (_install_location "../../../install")
endif()

set(NUMPY_PROCESS_ENVIRONMENT)
if(lapack_ENABLED)
  if(NOT LAPACK_FOUND)
    find_package(LAPACK REQUIRED)
  endif()
  list(APPEND NUMPY_PROCESS_ENVIRONMENT
    MKL "None"
    ATLAS "None"
    BLAS "${BLAS_LIBRARIES}"
    LAPACK "${LAPACK_LIBRARIES}"
  )
endif()

# If any variables are set, we must have the PROCESS_ENVIRONMENT keyword
if(NUMPY_PROCESS_ENVIRONMENT)
  list(INSERT NUMPY_PROCESS_ENVIRONMENT 0 PROCESS_ENVIRONMENT)
endif()

if(BUILD_SHARED_LIBS)
  add_external_project_or_use_system(numpy
    DEPENDS python
    CONFIGURE_COMMAND ""
    INSTALL_COMMAND
      ${pv_python_executable} setup.py install --prefix=${_install_location}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
      ${pv_python_executable} setup.py build --fcompiler=no
    ${NUMPY_PROCESS_ENVIRONMENT}
  )
else()
  add_external_project_or_use_system(numpy
    DEPENDS python
    CMAKE_ARGS
      -DPYTHON_EXECUTABLE=${pv_python_executable}
      -DPYTHON_INCLUDE_DIR=${pv_python_include_dir}
    ${NUMPY_PROCESS_ENVIRONMENT}
  )
endif()
