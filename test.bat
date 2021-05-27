@echo off
setlocal ENABLEDELAYEDEXPANSION

if "%1"=="" (
    echo Expected vcpkg root as first argument.
    exit 1
)

if "%2"=="" (
    echo Expected triplet as second argument.
    exit 1
)

set VCPKG_ROOT=%1
set TRIPLET=%2

echo Testing triplet %TRIPLET%

rem Get pkg-config executable
set PKG_CONFIG=%VCPKG_ROOT%\installed\%TRIPLET%\tools\pkgconf\pkgconf.exe
if not exist %PKG_CONFIG% (
  echo pkg-config executable not found
  echo please run "vcpkg install pkgconf:%TRIPLET%"
  exit 1
)

rem Get msvc runtime library from triplet
if "%TRIPLET:~-7%" == "-static" (
    set MSVC_RUNTIME_LIBRARY_RELEASE=MultiThreaded
    set MSVC_RUNTIME_LIBRARY_DEBUG=MultiThreadedDebug
) else (
    set MSVC_RUNTIME_LIBRARY_RELEASE=MultiThreadedDLL
    set MSVC_RUNTIME_LIBRARY_DEBUG=MultiThreadedDebugDLL
)
echo MSVC runtime library (release): %MSVC_RUNTIME_LIBRARY_RELEASE%
echo MSVC runtime library (debug): %MSVC_RUNTIME_LIBRARY_DEBUG%

rem Get list of all ffmpeg features from vcpkg list
for /f "tokens=1" %%G in ('%VCPKG_ROOT%\vcpkg.exe list ^| findstr /c:"ffmpeg:%TRIPLET% "') do (
    set ALL_FEATURES=core
)
if not "%ALL_FEATURES%" == "core" (
    echo ffmpeg:%TRIPLET% not installed
    echo please run "vcpkg install ffmpeg:%TRIPLET%"
    exit 1
)
for /f "delims=[] tokens=2" %%G in ('%VCPKG_ROOT%\vcpkg.exe list ^| findstr /r /c:"ffmpeg\[.*\]:%TRIPLET%[ ]"') do (
    set ALL_FEATURES=!ALL_FEATURES!;%%G
)
if %ERRORLEVEL% neq 0 ( exit )
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
cmake %~dp0\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY_RELEASE%
if %ERRORLEVEL% neq 0 ( exit )
cmake --build .
if %ERRORLEVEL% neq 0 ( exit )
ctest -V
if %ERRORLEVEL% neq 0 ( exit )

rem Test debug
mkdir %~dp0\test-%TRIPLET%-dbg
cd %~dp0\test-%TRIPLET%-dbg
cmake %~dp0\test -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=%TRIPLET% -DFEATURES=%ALL_FEATURES% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME_LIBRARY_DEBUG%
if %ERRORLEVEL% neq 0 ( exit )
cmake --build .
if %ERRORLEVEL% neq 0 ( exit )
ctest -V
if %ERRORLEVEL% neq 0 ( exit )
