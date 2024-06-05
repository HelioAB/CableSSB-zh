@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="HelioHonorV14" (taskkill /f /pid 20248)
if /i "%LOCALHOST%"=="HelioHonorV14" (taskkill /f /pid 9044)
if /i "%LOCALHOST%"=="HelioHonorV14" (taskkill /f /pid 7608)
if /i "%LOCALHOST%"=="HelioHonorV14" (taskkill /f /pid 6060)

del /F cleanup-ansys-HelioHonorV14-6060.bat
