#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${CODE_SIGN_IDENTITY:-}" || "$CODE_SIGN_IDENTITY" == "-" ]]; then
    echo "CODE_SIGN_IDENTITY must be set to a Developer ID Application identity." >&2
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift test
./scripts/build-app.sh
./scripts/package-dmg.sh
./scripts/notarize-dmg.sh "release/Exposé IP Address.dmg"

spctl --assess --type open --verbose "release/Exposé IP Address.dmg"

echo "Signed release is ready at release/Exposé IP Address.dmg"
