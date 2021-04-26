@echo off
setlocal ENABLEDELAYEDEXPANSION
if "%1"=="" (
    echo Expected triplet as argument.
    exit 1
)

set TRIPLET=%1

echo Testing triplet %TRIPLET%

rem Get msvc runtime library from triplet
if "%TRIPLET:~-7%" == "-static" (
    set MSVC_RUNTIME_LIBRARY=MultiThreaded
) else (
    set MSVC_RUNTIME_LIBRARY=MultiThreadedDLL
)
echo MSVC runtime library: %MSVC_RUNTIME_LIBRARY%

rem Get list of all ffmpeg features from vcpkg list
set ALL_FEATURES=core
for /f "delims=[] tokens=2" %%G in ('.\vcpkg\vcpkg.exe list ^| findstr "ffmpeg\[.*\]:%TRIPLET%"') do (
    set ALL_FEATURES=!ALL_FEATURES!;%%G
)
echo ffmpeg features: %ALL_FEATURES%

rem Set up developer prompt
if "%TRIPLET:~0,4%" == "x64-" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
) else (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"
)

rem Test release
mkdir %~dp0\test-%TRIPLET%-rel
cd %~dp0\test-%TRIPLET%-rel
cmake %~dp0\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=%~dp0\vcpkg\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY%
if %ERRORLEVEL% neq 0 ( exit )
cmake --build .
if %ERRORLEVEL% neq 0 ( exit )
ctest -V
if %ERRORLEVEL% neq 0 ( exit )

rem Test debug
mkdir %~dp0\test-%TRIPLET%-dbg
cd %~dp0\test-%TRIPLET%-dbg
cmake %~dp0\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_TOOLCHAIN_FILE=%~dp0\vcpkg\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY%
if %ERRORLEVEL% neq 0 ( exit )
cmake --build .
if %ERRORLEVEL% neq 0 ( exit )
ctest -V
if %ERRORLEVEL% neq 0 ( exit )
