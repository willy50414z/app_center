@echo off
cd /d E:\code\app_center
flutter clean >nul 2>&1
flutter build apk --debug
echo.
echo Build complete: build\app\outputs\flutter-apk\app-debug.apk
pause