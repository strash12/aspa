@echo off
REM run_matlab.bat - Запуск MATLAB скриптов из командной строки
REM Использование: run_matlab.bat <script_name> [script_directory]
REM Пример: run_matlab.bat adaptive_guard_comparison.m C:\path\to\script

set MATLAB_EXE=E:\matlab\R2023a\bin\matlab.exe
set SCRIPT_NAME=%1
set SCRIPT_DIR=%2

if "%SCRIPT_NAME%"=="" (
    echo Usage: run_matlab.bat ^<script_name.m^> [script_directory]
    exit /b 1
)

if "%SCRIPT_DIR%"=="" (
    set SCRIPT_DIR=%CD%
)

echo Running MATLAB script: %SCRIPT_NAME%
echo Working directory: %SCRIPT_DIR%

%MATLAB_EXE% -nosplash -nodesktop -wait -batch "cd('%SCRIPT_DIR%'); run('%SCRIPT_NAME%'); exit;"

echo MATLAB script completed.
