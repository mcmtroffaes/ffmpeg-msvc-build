@echo on
curl -o source.tar.xz https://ffmpeg.zeranoe.com/builds/source/ffmpeg/ffmpeg-%FFMPEG_VERSION%.tar.xz
7z x source.tar.xz
7z x source.tar
mkdir c:\yasm
set PATH=c:\yasm;%PATH%
if "%PLATFORM%" == "x64" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe
if "%PLATFORM%" == "x86" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe
