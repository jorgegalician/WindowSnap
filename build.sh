#!/bin/zsh
set -e
cd "$(dirname "$0")"
APP=build/WindowSnap.app
rm -rf build && mkdir -p $APP/Contents/MacOS $APP/Contents/Resources build/icon.iconset
swiftc -O -o $APP/Contents/MacOS/WindowSnap main.swift
swiftc -O -o build/icongen icon.swift && build/icongen build/icon1024.png
for sz in 16 32 128 256 512; do
  sips -z $sz $sz build/icon1024.png --out build/icon.iconset/icon_${sz}x${sz}.png >/dev/null
  sips -z $((sz*2)) $((sz*2)) build/icon1024.png --out build/icon.iconset/icon_${sz}x${sz}@2x.png >/dev/null
done
iconutil -c icns build/icon.iconset -o $APP/Contents/Resources/AppIcon.icns
cat > $APP/Contents/Info.plist <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>WindowSnap</string>
<key>CFBundleDisplayName</key><string>WindowSnap</string>
<key>CFBundleIdentifier</key><string>com.jorgegalician.windowsnap</string>
<key>CFBundleExecutable</key><string>WindowSnap</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>11.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
P
strip -x $APP/Contents/MacOS/WindowSnap
codesign --force --sign - $APP
du -sh $APP
