@echo on
cd C:\Tools\vcpkg
git pull
.\bootstrap-vcpkg.bat
cd %APPVEYOR_BUILD_FOLDER%
@echo off
