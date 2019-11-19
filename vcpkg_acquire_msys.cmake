## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
## Adapted to use the internal version installed by appveyor.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR> [PACKAGES <package>...])
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)`
##
## ## Notes
## A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT)
## set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
##
## vcpkg_execute_required_process(
##     COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
##     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
##     LOGNAME build-${TARGET_TRIPLET}-rel
## )
## ```
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
## * [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH C:/msys64)

  cmake_parse_arguments(_am "" "" "PACKAGES" ${ARGN})

  if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "vcpkg_acquire_msys() can only be used on Windows hosts")
  endif()

  set(PATH_TO_ROOT ${TOOLPATH})

  if(_am_PACKAGES)
    message(STATUS "Acquiring MSYS Packages...")
    string(REPLACE ";" " " _am_PACKAGES "${_am_PACKAGES}")

    set(_ENV_ORIGINAL $ENV{PATH})
    set(ENV{PATH} ${PATH_TO_ROOT}/usr/bin)
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Sy --noconfirm --needed ${_am_PACKAGES}"
      WORKING_DIRECTORY ${DOWNLOADS}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

  # Deal with a stale process created by MSYS
  if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
      vcpkg_execute_required_process(
          ALLOW_IN_DOWNLOAD_MODE
          COMMAND TASKKILL /F /IM gpg-agent.exe /fi "memusage gt 2"
          WORKING_DIRECTORY ${SOURCE_PATH}
      )
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
