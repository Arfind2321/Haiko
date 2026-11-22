@echo off

ECHO [INFO] Detecting git
where /q git
IF ERRORLEVEL 1 (
    ECHO [FATAL] Git wasn't found. Install GIT here: https://git-scm.com/install/windows
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Git detected
)

ECHO [INFO] Detecting docker
where /q docker
IF ERRORLEVEL 1 (
    ECHO [FATAL] Docker wasn't found. Install Docker here: https://www.docker.com/get-started/
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Docker detected
)

ECHO [INFO] Detecting flutter
where /q flutter
IF ERRORLEVEL 1 (
    ECHO [FATAL] Flutter wasn't found. Install Flutter here: https://docs.flutter.dev/install
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Flutter detected
)

ECHO [INFO] Cloning repository... 
call git clone https://github.com/Arfind2321/Haiko.git


if %ERRORLEVEL% NEQ 0 (
    ECHO [FATAL] Failed cloning repository
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Repository cloned successfully
)

cd Haiko/src

ECHO [INFO] Compileing frontend (web)...
cd app
call flutter build web

if %ERRORLEVEL% NEQ 0 (
    ECHO [FATAL] Frontend build failed
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Frontend built successfully
)

ECHO [INFO] Starting servers...

cd ..

mkdir static
cd static
mkdir static
cd ..

call docker compose up -d

if %ERRORLEVEL% NEQ 0 (
    ECHO [FATAL] Servers start failed failed
    pause
    EXIT /B
) ELSE (
   ECHO [INFO] Servers started successfully
)

ECHO(
ECHO Service available at http://localhost/
ECHO(
ECHO At this stage, you can close the script without any consequences if you only need the web version. Otherwise, press any key, and the script will proceed to build the applications for Android and Windows.
ECHO macOS, iOS, and Linux are also supported but have not been tested; therefore, building clients for these platforms is not available in this script. You can build these applications manually by following the Flutter documentation: https://docs.flutter.dev/deployment. However, successful builds and full functionality are not guaranteed.
ECHO(

pause

ECHO "Please, change app/api/server_api.dart -> serverUrl to your device ip."

pause

ECHO [INFO] Building for windows...

cd app
call flutter build windows

if %ERRORLEVEL% NEQ 0 (
    ECHO [FATAL] Windows build failed
    pause
    EXIT /B
) ELSE (
    explorer build\windows\x64\runner\Release
    ECHO [INFO] Windows built successfully
)

ECHO Please, make sure that you have Android SDK 34 installed.

pause

ECHO [INFO] Building for android (apk)...

call flutter build apk

if %ERRORLEVEL% NEQ 0 (
    ECHO [FATAL] Android build failed
    pause
    EXIT /B
) ELSE (
    explorer build\app\outputs\flutter-apk
    ECHO [INFO] Android built successfully
)

ECHO [INFO] Everything built successfuly
