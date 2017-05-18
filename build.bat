rem set up Visual Studio 2015 64-bit environment
rem see https://www.appveyor.com/docs/lang/cpp/
rem (differenes: no need for SDK, use native amd64 instead of x86_amd64)
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64

rem run main build script
C:\msys64\usr\bin\bash -lc "$APPVEYOR_BUILD_FOLDER/build.sh"

