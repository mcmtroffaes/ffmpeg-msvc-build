cmake_minimum_required(VERSION 3.12)
set(TYPE pkgconfig)
set(COMPONENT postproc)
set(TEST test_${TYPE}_${COMPONENT})
set(SRC_DIR ../../src/${COMPONENT})
project(${TEST})
find_package(PkgConfig REQUIRED)
pkg_check_modules(POSTPROC REQUIRED IMPORTED_TARGET libpostproc)
find_package(fmt CONFIG REQUIRED)
add_executable            (${TEST} ${SRC_DIR}/main.cpp)
target_link_libraries     (${TEST} PRIVATE PkgConfig::POSTPROC fmt::fmt)
add_test(${TEST} ${TEST})
