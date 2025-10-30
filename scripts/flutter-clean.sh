#!/bin/bash
# Flutter cleanup script - cleans caches safely
echo "🧹 Cleaning Flutter caches..."
cd frontend 2>/dev/null || { echo "❌ frontend directory not found"; exit 1; }

# Clean Dart tool cache (this is safe to delete)
rm -rf .dart_tool 2>/dev/null || rmdir /s /q .dart_tool 2>/dev/null

# Deep clean option - includes build directory and lockfile
if [ "$1" = "--deep" ]; then
    echo "🔥 Deep clean: removing build directory and lockfile..."
    rm -rf build 2>/dev/null || rmdir /s /q build 2>/dev/null
    rm -f pubspec.lock
fi

echo "✅ Flutter cleanup completed"