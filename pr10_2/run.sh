#!/bin/bash
cd "$(dirname "$0")" || exit 1
export PATH="/Users/denysklymenko/CollegeProjects/FlutterSDK/flutter/bin:$PATH"
echo "=== Запуск системи замовлень (Order System) на macOS ==="
flutter run -d macos
