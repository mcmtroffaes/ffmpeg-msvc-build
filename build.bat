@echo on
rem set up Visual Studio 2017 64-bit environment for v140 toolset
rem see https://www.appveyor.com/docs/lang/cpp/
rem and https://stackoverflow.com/a/46994531
rem (differenes: no need for SDK, use native amd64 instead of x86_amd64)
if "%TOOLSET%" == "v140" (
  if "%PLATFORM%" == "x64" call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" -vcvars_ver=14.0
  if "%PLATFORM%" == "x86" call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" -vcvars_ver=14.0
)
if "%TOOLSET%" == "v141" (
  if "%PLATFORM%" == "x64" call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" -vcvars_ver=14.1
  if "%PLATFORM%" == "x86" call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" -vcvars_ver=14.1
)
rem run main build script
C:\msys64\usr\bin\bash -lc "$APPVEYOR_BUILD_FOLDER/build.sh"
@echo off
