# Exposé IP Address

A tiny macOS Swift menu bar app that shows your preferred local IPv4 address in the status bar.

## Run

```sh
swift run ExposeIPAddress
```

The menu bar item shows the primary local IP address macOS is using for outbound traffic. Its menu includes:

- all active local IPv4 addresses, grouped by interface with Wi-Fi/LAN icons
- `Copy Primary IP`
- `Refresh`
- `Launch at Login`
- `Quit`

## Test

```sh
swift test
```

## Build an app bundle

```sh
./scripts/build-app.sh
```

The script creates `dist/Exposé IP Address.app`.
