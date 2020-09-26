@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0export.ps1' %*}"