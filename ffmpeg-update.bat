@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0ffmpeg-update.ps1' %*}"