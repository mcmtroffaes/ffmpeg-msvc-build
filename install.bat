@echo on
git submodule update --init --recursive --depth 1000
if not exist c:\nasm-2.13.03-win64.zip ( curl -o c:\nasm-2.13.03-win64.zip https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/win64/nasm-2.13.03-win64.zip )
7z x c:\nasm-2.13.03-win64.zip -oc:\
dir /s /b c:\nasm-2.13.03
set PATH=c:\nasm-2.13.03;%PATH%
@echo off
