@echo on
git submodule update --init --recursive --depth 100
mkdir c:\nasm
set PATH=c:\nasm;%PATH%
if "%PLATFORM%" == "x64" curl -o "c:\nasm.zip" http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/win64/nasm-2.13.01-win64.zip
if "%PLATFORM%" == "x86" curl -o "c:\nasm.zip" http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/win32/nasm-2.13.01-win32.zip
unzip c:\nasm.zip
move nasm-2.13.01\nasm.exe c:\nasm
@echo off
