#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${APPLE_DEVELOPER_ID_CERTIFICATE_BASE64:-}" || -z "${APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD:-}" ]]; then
    echo "APPLE_DEVELOPER_ID_CERTIFICATE_BASE64 and APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD are required." >&2
    exit 1
fi

WORK_DIR="${RUNNER_TEMP:-/tmp}/expose-ip-address-signing"
KEYCHAIN_PATH="$WORK_DIR/developer-id.keychain-db"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-$(uuidgen)}"
CERTIFICATE_PATH="$WORK_DIR/developer-id.p12"

mkdir -p "$WORK_DIR"

if ! printf '%s' "$APPLE_DEVELOPER_ID_CERTIFICATE_BASE64" | base64 --decode > "$CERTIFICATE_PATH" 2>/dev/null; then
    printf '%s' "$APPLE_DEVELOPER_ID_CERTIFICATE_BASE64" | base64 -D > "$CERTIFICATE_PATH"
fi

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$CERTIFICATE_PATH" \
    -P "$APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD" \
    -A \
    -t cert \
    -f pkcs12 \
    -k "$KEYCHAIN_PATH"

existing_keychains="$(security list-keychains -d user | tr -d '"')"
security list-keychains -d user -s "$KEYCHAIN_PATH" $existing_keychains
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security find-identity -v -p codesigning "$KEYCHAIN_PATH"
