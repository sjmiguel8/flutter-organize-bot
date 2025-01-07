#!/bin/bash

# Enable macOS
flutter config --enable-macos-desktop

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build macOS app
flutter build macos

# Clean up any existing DMG or mounted volumes
rm -f OrganizeBot.dmg
diskutil unmount force /Volumes/dmg.* 2>/dev/null || true
diskutil unmount force /Volumes/Organize\ Bot 2>/dev/null || true

# Create DMG
create-dmg \
  --volname "Organize Bot" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "OrganizeBot.dmg" \
  "build/macos/Build/Products/Release/fluttertry.app" || {
    # If create-dmg fails, try to clean up
    diskutil unmount force /Volumes/dmg.* 2>/dev/null || true
    diskutil unmount force /Volumes/Organize\ Bot 2>/dev/null || true
    exit 1
  } 