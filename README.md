# Exposé IP Address

Exposé IP Address is a small macOS menu bar app that shows your Mac's local IP address at a glance.

It is useful when you are setting up local servers, testing devices on the same network, sharing a development URL, or switching between Wi-Fi and Ethernet and just need to know which IP your Mac is actually using.

## What It Does

- Shows your primary local IP address directly in the menu bar
- Lists active Wi-Fi, Ethernet/LAN, and other local IPv4 addresses
- Lets you copy the primary IP or any listed interface IP
- Refreshes automatically when your network changes
- Can launch automatically when you log in
- Includes a simple About window with version and privacy details

## Download

Download the latest DMG from the releases page:

https://github.com/xorica27/expose-ip-address/releases/latest

Open the DMG, then drag `Exposé IP Address.app` into `Applications`.

For the smoothest first launch, public DMGs should be Developer ID signed and notarized by Apple. If you see a macOS warning that the app cannot be opened, use the latest notarized release or see [SUPPORT.md](SUPPORT.md).

## How To Use

After opening the app, your primary local IP appears in the macOS menu bar.

Click the IP address to open the menu. From there you can:

- copy the primary IP
- copy a specific Wi-Fi or LAN IP
- refresh the address list
- turn Launch at Login on or off
- view app/version details
- quit the app

## Privacy

Exposé IP Address stays local. It reads macOS network interface information so it can display your local IP addresses, and it does not send analytics, telemetry, IP addresses, or any other data off your Mac.

See [PRIVACY.md](PRIVACY.md) for the full privacy note.

## Support

If the menu bar shows `No IP`, make sure your Mac is connected to a network with a valid IPv4 address. Self-assigned `169.254.x.x` addresses are ignored.

More help is available in [SUPPORT.md](SUPPORT.md).

## Development

Requirements:

- macOS 13 or newer
- Swift 6 / Xcode command line tools

Run from source:

```sh
swift run ExposeIPAddress
```

Run tests:

```sh
swift test
```

Build the app bundle:

```sh
./scripts/build-app.sh
```

The app bundle is created at `dist/Exposé IP Address.app`.

Package a DMG with DMGForge:

```sh
./scripts/build-app.sh
./scripts/package-dmg.sh
```

The DMG is created at `release/Exposé IP Address.dmg`.

## Release Signing

Local development builds are ad-hoc signed and are not notarized.

For public distribution, use a Developer ID Application certificate and Apple notarization credentials. This prevents the extra Security Settings > Open Anyway step for users downloading the DMG.

```sh
export CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export APPLE_ID="you@example.com"
export APPLE_TEAM_ID="TEAMID"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"

./scripts/build-signed-release.sh
```

The GitHub release workflow is manual-only until signing/notarization secrets are configured. It expects:

- `CODE_SIGN_IDENTITY`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `APPLE_DEVELOPER_ID_CERTIFICATE_BASE64`
- `APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD`
- `DMGFORGE_CLI_URL`, a zip URL containing a `dmgforge` executable at the archive root

Create `APPLE_DEVELOPER_ID_CERTIFICATE_BASE64` from the exported `.p12` certificate:

```sh
base64 -i DeveloperIDApplication.p12 | tr -d '\n' | pbcopy
```

## License

Exposé IP Address is released under the [MIT License](LICENSE).
