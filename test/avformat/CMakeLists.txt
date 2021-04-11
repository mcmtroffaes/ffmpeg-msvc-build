cmake_minimum_required(VERSION 3.12)
project(test_avformat)
find_package(FFMPEG REQUIRED)
add_executable(test_decode decode.cpp)
target_link_libraries(test_decode PRIVATE ${FFMPEG_LIBRARIES})
target_include_directories(test_decode PRIVATE ${FFMPEG_INCLUDE_DIRS})
add_executable(list_all_protocols list_all_protocols.cpp)
target_link_libraries(list_all_protocols PRIVATE ${FFMPEG_LIBRARIES})
target_include_directories(list_all_protocols PRIVATE ${FFMPEG_INCLUDE_DIRS})
add_executable(test_find_protocol find_protocol.cpp)
target_link_libraries(test_find_protocol PRIVATE ${FFMPEG_LIBRARIES})
target_include_directories(test_find_protocol PRIVATE ${FFMPEG_INCLUDE_DIRS})
if("avisynthplus" IN_LIST FEATURES)
  add_custom_command(
    TARGET test_decode POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
      "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/AviSynth${CMAKE_SHARED_LIBRARY_SUFFIX}"
      $<TARGET_FILE_DIR:test_decode>)
endif()