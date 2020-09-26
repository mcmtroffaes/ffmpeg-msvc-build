function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  message(STATUS "Using AppVeyor MSYS")
  set(${PATH_TO_ROOT_OUT} "C:/msys64" PARENT_SCOPE)
endfunction()
