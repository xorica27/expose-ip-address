# Support

## Troubleshooting

### The menu bar shows `No IP`

Make sure Wi-Fi, Ethernet, or another network interface is connected and has a valid IPv4 address. Self-assigned `169.254.x.x` addresses are ignored.

### The app does not appear in the menu bar

Quit any older copy of the app, then open the app from `/Applications`. If you are testing a development build, run:

```sh
pkill -x ExposeIPAddress || true
open "dist/Exposé IP Address.app"
```

### Launch at Login does not work

Move the app to `/Applications`, open it once, and enable `Launch at Login` from the menu bar menu.

### macOS says the app cannot be opened

macOS shows this warning when an app is not Developer ID signed and notarized by Apple.

For the best install experience, download the latest public release. Public release DMGs should be Developer ID signed, notarized, and stapled so users can open the app after dragging it into `Applications`.

While the app is distributed unsigned, the DMG includes `First Launch Help.txt` and `Open Security Settings`. If macOS blocks the first launch, click `Done`, open `Open Security Settings` from the DMG, then click `Open Anyway` for Exposé IP Address in Privacy & Security.

If you built the app yourself from source, macOS may still show this warning because local development builds are ad-hoc signed.

## Reporting Issues

Open an issue at:

https://github.com/xorica27/expose-ip-address/issues
