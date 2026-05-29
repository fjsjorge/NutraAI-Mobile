@echo off
rem ------------------------------------------------------------
rem Script: create_nutraai_avd.bat
rem Purpose: Create an Android Virtual Device (AVD) pre‑configured for testing NutraAI‑Mobile.
rem ------------------------------------------------------------

:: ----------------------------------------------------------------
:: Prerequisites
::   - Android SDK installed (including "cmdline-tools" and "platform-tools").
::   - Environment variable %ANDROID_SDK_ROOT% points to the SDK root.
::   - SDK Manager must be available in PATH (or use full path below).
:: ----------------------------------------------------------------

:: Helper to locate a tool inside the SDK
:find_tool
set "TOOL_NAME=%~1"
if defined ANDROID_SDK_ROOT (
    for %%F in ("%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\%TOOL_NAME%*.bat") do (
        if exist "%%F" set "TOOL_PATH=%%F"
    )
    if defined TOOL_PATH goto :eof
    for %%F in ("%ANDROID_SDK_ROOT%\cmdline-tools\%TOOL_NAME%*.bat") do (
        if exist "%%F" set "TOOL_PATH=%%F"
    )
)
rem Fallback to PATH
where %TOOL_NAME% >nul 2>&1 && set "TOOL_PATH=%TOOL_NAME%"
:eof
exit /b 0

:: ----------------------------------------------------------------
:: Verify SDK tools
call :find_tool sdkmanager
if not defined TOOL_PATH (
    echo [!] sdkmanager not found. Install Android SDK command‑line tools and add them to PATH.
    exit /b 1
)
set "SDKMANAGER=%TOOL_PATH%"

call :find_tool avdmanager
if not defined TOOL_PATH (
    echo [!] avdmanager not found. Ensure "cmdline-tools" are installed.
    exit /b 1
)
set "AVDMANAGER=%TOOL_PATH%"

:: ----------------------------------------------------------------
:: Install required platform and system‑image if missing
set "PLATFORM=platforms;android-33"
set "SYSIMG=system-images;android-33;google_apis;x86_64"

%SDKMANAGER% "%PLATFORM%" "%SYSIMG%" --sdk_root=%ANDROID_SDK_ROOT% --silent
if errorlevel 1 (
    echo [!] Failed to install platform or system image.
    exit /b 1
)

:: ----------------------------------------------------------------
:: Create the AVD (named nutraai_avd)
set "AVD_NAME=nutraai_avd"
rem Check if AVD already exists
%AVDMANAGER% list avd | findstr /I "%AVD_NAME%" >nul
if not errorlevel 1 (
    echo [i] AVD "%AVD_NAME%" already exists – skipping creation.
    goto :launch
)

%AVDMANAGER% create avd -n "%AVD_NAME%" -k "%SYSIMG%" -d "pixel" --force
if errorlevel 1 (
    echo [!] AVD creation failed.
    exit /b 1
) else (
    echo [✔] AVD "%AVD_NAME%" created successfully.
)

:launch
rem ----------------------------------------------------------------
rem Optional: start the emulator immediately (requires "emulator.exe" in PATH)
where emulator >nul 2>&1
if not errorlevel 1 (
    echo Starting emulator "%AVD_NAME%" ...
    start "" emulator -avd %AVD_NAME% -netdelay none -netspeed full
) else (
    echo [i] "emulator" command not found – you can start the AVD later via Android Studio or command line.
)

exit /b 0
