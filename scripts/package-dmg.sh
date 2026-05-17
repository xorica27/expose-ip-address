#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/packaging/expose-ip-address.dmgproject"
OUTPUT_PATH="$ROOT_DIR/release/Exposé IP Address.dmg"
RW_OUTPUT_PATH="$ROOT_DIR/release/Exposé IP Address-rw.dmg"
EXTRA_FILES_DIR="$ROOT_DIR/release/dmg-extra-files"

cd "$ROOT_DIR"

if ! command -v dmgforge >/dev/null 2>&1; then
    echo "dmgforge CLI is required. Install DMGForge and run scripts/install-cli.sh from that project." >&2
    exit 1
fi

mkdir -p "$ROOT_DIR/release"
rm -rf "$ROOT_DIR/release/dmgforge-work" "$OUTPUT_PATH" "$RW_OUTPUT_PATH" "$EXTRA_FILES_DIR"

dmgforge validate "$PROJECT_PATH"
dmgforge export "$PROJECT_PATH" --output "$OUTPUT_PATH"
mkdir -p "$EXTRA_FILES_DIR"

cat > "$EXTRA_FILES_DIR/Open Security Settings.inetloc" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>URL</key>
    <string>x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension</string>
</dict>
</plist>
PLIST

cat > "$EXTRA_FILES_DIR/First Launch Help.txt" <<'TXT'
First launch help

1. Drag Exposé IP Address into Applications.
2. Open Exposé IP Address from Applications.
3. If macOS says the app cannot be opened, click Done.
4. Double-click Open Security Settings in this window.
5. In Privacy & Security, click Open Anyway for Exposé IP Address.
6. Click Open when macOS asks one more time.

After this approval, the app should open normally.
TXT

hdiutil convert "$OUTPUT_PATH" -format UDRW -o "$RW_OUTPUT_PATH" >/dev/null
rm -f "$OUTPUT_PATH"

ATTACH_OUTPUT="$(hdiutil attach "$RW_OUTPUT_PATH" -readwrite -noverify -noautoopen)"
MOUNT_POINT="$(printf '%s\n' "$ATTACH_OUTPUT" | sed -nE 's#^/dev/[^[:space:]]+[[:space:]]+Apple_HFS[[:space:]]+(.+)$#\1#p' | tail -n 1)"

if [[ -z "$MOUNT_POINT" || ! -d "$MOUNT_POINT" ]]; then
    echo "Could not find mounted DMG volume." >&2
    printf '%s\n' "$ATTACH_OUTPUT" >&2
    exit 1
fi

cleanup_mount() {
    hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true
}
trap cleanup_mount EXIT

cp "$EXTRA_FILES_DIR/Open Security Settings.inetloc" "$MOUNT_POINT/Open Security Settings.inetloc"
cp "$EXTRA_FILES_DIR/First Launch Help.txt" "$MOUNT_POINT/First Launch Help.txt"

osascript <<APPLESCRIPT >/dev/null
tell application "Finder"
  set dmgFolder to POSIX file "$MOUNT_POINT" as alias
  tell folder dmgFolder
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set sidebar width of container window to 0
    set bounds of container window to {140, 140, 820, 700}

    set viewOptions to icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 96

    set position of item "Exposé IP Address.app" of container window to {190, 210}
    set position of item "Applications" of container window to {500, 210}
    set position of item "Open Security Settings.inetloc" of container window to {190, 420}
    set position of item "First Launch Help.txt" of container window to {500, 420}

    update without registering applications
    delay 1
    close
  end tell
end tell
APPLESCRIPT

hdiutil detach "$MOUNT_POINT" >/dev/null
trap - EXIT

hdiutil convert "$RW_OUTPUT_PATH" -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_PATH" >/dev/null
rm -f "$RW_OUTPUT_PATH"

if [[ -n "${CODE_SIGN_IDENTITY:-}" && "${CODE_SIGN_IDENTITY}" != "-" ]]; then
    codesign --force --timestamp --sign "$CODE_SIGN_IDENTITY" "$OUTPUT_PATH" >/dev/null
fi

hdiutil verify "$OUTPUT_PATH" >/dev/null
rm -rf "$EXTRA_FILES_DIR"

echo "Packaged $OUTPUT_PATH"
