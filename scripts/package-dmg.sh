#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/packaging/expose-ip-address.dmgproject"
OUTPUT_PATH="$ROOT_DIR/release/Exposé IP Address.dmg"

cd "$ROOT_DIR"

if ! command -v dmgforge >/dev/null 2>&1; then
    echo "dmgforge CLI is required. Install DMGForge and run scripts/install-cli.sh from that project." >&2
    exit 1
fi

mkdir -p "$ROOT_DIR/release"
rm -rf "$ROOT_DIR/release/dmgforge-work" "$OUTPUT_PATH"

dmgforge validate "$PROJECT_PATH"
dmgforge export "$PROJECT_PATH" --output "$OUTPUT_PATH"
hdiutil verify "$OUTPUT_PATH" >/dev/null

echo "Packaged $OUTPUT_PATH"
