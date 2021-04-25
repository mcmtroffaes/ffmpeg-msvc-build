@echo on
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
mkdir %HOMEDRIVE%%HOMEPATH%\build-rel
cd %HOMEDRIVE%%HOMEPATH%\build-rel
cmake %HOMEDRIVE%%HOMEPATH%\project\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=%HOMEDRIVE%%HOMEPATH%\project\vcpkg\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY%
cmake --build .
ctest -V
mkdir %HOMEDRIVE%%HOMEPATH%\build-dbg
cd %HOMEDRIVE%%HOMEPATH%\build-dbg
cmake %HOMEDRIVE%%HOMEPATH%\project\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_TOOLCHAIN_FILE=%HOMEDRIVE%%HOMEPATH%\project\vcpkg\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY%
cmake --build .
ctest -V
