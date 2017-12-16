@echo on
git submodule update --init --recursive --depth 100
if not exist c:\nasm-2.13.01-win64.zip ( curl -o c:\nasm-2.13.01-win64.zip http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/win64/nasm-2.13.01-win64.zip )
7z x c:\nasm-2.13.01-win64.zip -oc:\
dir /s /b c:\nasm-2.13.01
set PATH=c:\nasm-2.13.01;%PATH%
@echo off
