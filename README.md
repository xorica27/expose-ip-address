# Local IP Menu Bar

A tiny macOS Swift menu bar app that shows your preferred local IPv4 address in the status bar.

## Run

```sh
swift run LocalIPMenuBar
```

The menu bar item shows the detected local IP address. Its menu includes:

- `Copy IP Address`
- `Refresh`
- `Quit`

## Test

```sh
swift test
```

## Build an app bundle

```sh
./scripts/build-app.sh
```

The script creates `dist/Local IP Menu Bar.app`.
