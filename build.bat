@echo off
flutter build apk --release
copy build\app\outputs\flutter-apk\app-release.apk C:\Users\DELL\Downloads\FitGlow.apk
