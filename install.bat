@echo on
git submodule update --init --recursive --depth 100
mkdir c:\yasm
set PATH=c:\yasm;%PATH%
if "%PLATFORM%" == "x64" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe
if "%PLATFORM%" == "x86" curl -o "c:\yasm\yasm.exe" http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe
