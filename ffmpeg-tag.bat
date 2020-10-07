@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0ffmpeg-tag.ps1' %*}"