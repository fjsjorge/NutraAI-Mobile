@echo off
rem ------------------------------------------------------------
rem Script: install_nutraai.bat
rem Purpose: Install NutraAI-Mobile APK on a connected Android device or running emulator using ADB.
rem ------------------------------------------------------------

:: Check that ADB is available
where adb >nul 2>&1
if errorlevel 1 (
    echo [!] ADB (Android Debug Bridge) not found in PATH.
    echo     Please install Android SDK Platform-Tools and add %ANDROID_SDK_ROOT%\platform-tools to your PATH.
    exit /b 1
)

:: Verify a device is connected (or an emulator is running)
adb devices | findstr /R "\tdevice" >nul
if errorlevel 1 (
    echo [!] No connected Android device or running emulator detected.
    echo     Connect a device via USB (enable USB debugging) or start an Android emulator.
    exit /b 1
)

:: Locate the APK – user should place the downloaded APK in this folder
set "APK_PATH=%~dp0NutraAI.apk"
if not exist "%APK_PATH%" (
    echo [!] NutraAI.apk not found in %~dp0.
    echo     Download the APK (official build from the Play Store or provided by the vendor) and rename it to NutraAI.apk.
    exit /b 1
)

:: Install / update the APK
echo Installing NutraAI.apk on the device...
adb install -r "%APK_PATH%"
if errorlevel 1 (
    echo [!] Installation failed. Check the device logs with "adb logcat" for details.
    exit /b 1
) else (
    echo [✔] Installation succeeded!
)

:: Optional: launch the app automatically (replace with the actual package name if known)
rem You can discover the package name with "adb shell pm list packages | findstr /i nutr"
rem set "PACKAGE=com.example.nutraai"  (replace)
rem adb shell monkey -p %PACKAGE% -c android.intent.category.LAUNCHER 1

exit /b 0
