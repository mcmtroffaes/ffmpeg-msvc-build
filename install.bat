@echo on
git submodule update --init --recursive --depth 100
mkdir c:\yasm
set PATH=c:\yasm;%PATH%
if "%PLATFORM%" == "x64" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe
if "%PLATFORM%" == "x86" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe
mkdir c:\nasm
set PATH=c:\nasm;%PATH%
if "%PLATFORM%" == "x64" curl -o "nasm.zip" http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/win64/nasm-2.13.01-win64.zip
if "%PLATFORM%" == "x86" curl -o "nasm.zip" http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/win32/nasm-2.13.01-win32.zip
unzip nasm.zip
move nasm-2.13.01\nasm.exe c:\nasm
@echo off
