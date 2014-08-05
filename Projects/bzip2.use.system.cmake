find_package(Bzip2)

add_extra_cmake_args(
   -DBZIP2_INCLUDE_DIR:PATH=${BZIP2_INCLUDE_DIR}
   -DBZIP2_LIBRARIES:FILEPATH=${BZIP2_LIBRARIES}
)