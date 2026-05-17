#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Exposé IP Address"
BUNDLE_ID="com.xorica.expose-ip-address"
EXECUTABLE_NAME="ExposeIPAddress"
CONFIGURATION="release"

cd "$ROOT_DIR"

swift build -c "$CONFIGURATION"

BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICONSET_DIR="$ROOT_DIR/.build/AppIcon.iconset"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BIN_DIR/$EXECUTABLE_NAME" "$MACOS_DIR/$EXECUTABLE_NAME"
chmod +x "$MACOS_DIR/$EXECUTABLE_NAME"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"
sips -z 16 16 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$ROOT_DIR/Resources/AppIcon.png" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "Built $APP_DIR"
