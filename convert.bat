@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Memtest86 IMG → ISO Converter

echo.
echo ===============================
echo   Memtest86 IMG to ISO v1.0.0
echo ===============================
echo.

:: === Get the IMG file ===
if "%~1"=="" (
    echo Drag and drop your .img file here or paste the full path:
    set /p "INPUT_IMG=Path to IMG file: "
) else (
    set "INPUT_IMG=%~1"
)

set "INPUT_IMG=%INPUT_IMG:"=%"

if not exist "%INPUT_IMG%" (
    echo [ERROR] File not found: %INPUT_IMG%
    pause
    exit /b 1
)

set "TOOLS=%~dp0tools"
if not exist "%TOOLS%\7z.exe" (
    echo [ERROR] 7z.exe missing in tools\
    pause
    exit /b 1
)
if not exist "%TOOLS%\xorriso.exe" (
    echo [ERROR] xorriso.exe missing in tools\
    pause
    exit /b 1
)

for %%F in ("%INPUT_IMG%") do (
    set "INPUT_DIR=%%~dpF"
    set "INPUT_NAME=%%~nF"
)

set "WORK_DIR=%TEMP%\mt86_%RANDOM%"
set "EXTRACT_DIR=%WORK_DIR%\extract"
set "ESP_IMG=%WORK_DIR%\esp.img"
set "TEMP_ISO=%WORK_DIR%\MemTest86.iso"
set "OUTPUT_ISO=%INPUT_DIR%%INPUT_NAME%.iso"

echo Source file : %INPUT_IMG%
echo Output ISO  : %OUTPUT_ISO%
echo.

mkdir "%EXTRACT_DIR%" 2>nul

echo [1/4] Extracting partitions...
"%TOOLS%\7z.exe" x "%INPUT_IMG%" -o"%EXTRACT_DIR%" -y
if errorlevel 1 (
    echo [ERROR] 7z extraction failed
    goto :cleanup
)

echo.
echo Extracted content:
dir /b "%EXTRACT_DIR%"
echo.

:: Robust search for the EFI partition
set "EFI_PART="
for /f "delims=" %%F in ('dir /b "%EXTRACT_DIR%\*EFI*.img" 2^>nul') do (
    set "EFI_PART=%EXTRACT_DIR%\%%F"
)

if not defined EFI_PART (
    echo [ERROR] No *EFI*.img partition found
    goto :cleanup
)

echo [2/4] EFI partition found: %EFI_PART%
copy /Y "%EFI_PART%" "%ESP_IMG%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy EFI partition
    goto :cleanup
)

echo [3/4] Creating ISO...
echo.

:: Remove the extract folder so it doesn't end up inside the ISO
rd /s /q "%EXTRACT_DIR%" 2>nul

echo --- xorriso ---
pushd "%WORK_DIR%"
"%TOOLS%\xorriso.exe" -as mkisofs -iso-level 3 -full-iso9660-filenames -eltorito-alt-boot -e "esp.img" -no-emul-boot -o "MemTest86.iso" .
set "XORRISO_ERR=!errorlevel!"
popd
echo --- End of xorriso (exit code: !XORRISO_ERR!) ---
echo.

if !XORRISO_ERR! neq 0 (
    echo [ERROR] xorriso failed
    goto :cleanup
)

if not exist "%TEMP_ISO%" (
    echo [ERROR] MemTest86.iso was not created
    dir /b "%WORK_DIR%"
    goto :cleanup
)

echo Moving ISO to final location...
move /Y "%TEMP_ISO%" "%OUTPUT_ISO%" >nul
if errorlevel 1 (
    echo [ERROR] Failed to move the ISO
    goto :cleanup
)

echo [4/4] Cleaning up...
:cleanup
if exist "%WORK_DIR%" rd /s /q "%WORK_DIR%" 2>nul

if exist "%OUTPUT_ISO%" (
    echo.
    echo ========================================
    echo   SUCCESS!
    echo   %OUTPUT_ISO%
    echo ========================================
) else (
    echo.
    echo [FAILED] ISO was not created.
)

echo.
pause
endlocal