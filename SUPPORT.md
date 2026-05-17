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

Local development builds are ad-hoc signed. Public releases should be Developer ID signed and notarized.

## Reporting Issues

Open an issue at:

https://github.com/xorica27/expose-ip-address/issues
