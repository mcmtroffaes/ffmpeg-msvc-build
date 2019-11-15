@echo on
vcpkg install ffmpeg:x64-windows
vcpkg export ffmpeg:x64-windows --output=export --raw
dir export\installed\x64-windows\ /s /b
@echo off
