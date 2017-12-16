@echo on
rem set up Visual Studio environment for specified toolset and platform
rem see https://www.appveyor.com/docs/lang/cpp/
rem and https://stackoverflow.com/a/46994531
rem (differenes: no need for SDK, use native amd64 instead of x86_amd64)
if "%TOOLSET%" == "v120" (
  if "%PLATFORM%" == "x64" call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" amd64
  if "%PLATFORM%" == "x86" call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86
)
if "%TOOLSET%" == "v140" (
  if "%PLATFORM%" == "x64" call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
  if "%PLATFORM%" == "x86" call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
)
if "%TOOLSET%" == "v141" call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %PLATFORM% -vcvars_ver=14.1
rem run main build script
C:\msys64\usr\bin\bash -lc "$APPVEYOR_BUILD_FOLDER/build.sh"
@echo off
