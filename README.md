# Exposé IP Address

Exposé IP Address is a tiny macOS menu bar app that shows your primary local IPv4 address at a glance.

It is built for the practical “what IP is this Mac using right now?” moment, especially when Wi-Fi and LAN/Ethernet may both be connected.

## Features

- Shows the primary local IP address macOS is using for outbound traffic
- Lists all active local IPv4 addresses in the menu
- Uses Wi-Fi/LAN icons for interface rows
- Copies the primary IP or any listed interface IP
- Refreshes automatically when the network path changes
- Includes a Launch at Login toggle
- Includes an About window with version and privacy details

## Install

Download the latest DMG from the GitHub release page:

https://github.com/xorica27/expose-ip-address/releases/latest

Open the DMG, then drag `Exposé IP Address.app` into `Applications`.

## Run

```sh
swift run ExposeIPAddress
```

The menu bar item shows the primary local IP address macOS is using for outbound traffic. Its menu includes:

- all active local IPv4 addresses, grouped by interface with Wi-Fi/LAN icons
- `Copy Primary IP`
- `Refresh` and automatic network-change refresh
- `Launch at Login`
- `About Exposé IP Address`
- `Quit`

## Privacy

Exposé IP Address reads local macOS network interface information only. It does not send analytics, telemetry, IP addresses, or any other data off your Mac.

See [PRIVACY.md](PRIVACY.md).

## Test

```sh
swift test
```

## Build an app bundle

```sh
./scripts/build-app.sh
```

The script creates `dist/Exposé IP Address.app`.

## Package a DMG

Requires the `dmgforge` CLI from DMGForge:

```sh
./scripts/build-app.sh
./scripts/package-dmg.sh
```

The script creates `release/Exposé IP Address.dmg`.

## Signed Release Build

For public distribution, use a Developer ID Application certificate and Apple notarization credentials:

```sh
export CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export APPLE_ID="you@example.com"
export APPLE_TEAM_ID="TEAMID"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"

./scripts/build-signed-release.sh
```

Local development builds are ad-hoc signed and are not notarized.

The GitHub release workflow expects these repository secrets:

- `CODE_SIGN_IDENTITY`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `DMGFORGE_CLI_URL`, a zip URL containing a `dmgforge` executable at the archive root

## Support

See [SUPPORT.md](SUPPORT.md).
