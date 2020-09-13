cmake_minimum_required(VERSION 3.17)
project(test)
set(FEATURES "" CACHE STRING "List of all features enabled through vcpkg.")
enable_testing()
add_subdirectory(avutil)
if ("postproc" IN_LIST FEATURES)
  add_subdirectory(postproc)
endif()

