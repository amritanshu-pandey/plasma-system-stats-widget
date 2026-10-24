# System Stats

A Plasma 6 widget that shows CPU, memory, disk and network usage in the panel, inspired by [Stats](https://github.com/exelban/stats) for macOS.

Each module shows a small graph and its current value. Click a module to open a popup with more detail:

- **CPU**: total usage, user/system/wait split, frequency, temperature, per-core usage and top processes
- **Memory**: used, application, cache, buffers, free, swap and top processes
- **Disk**: read and write rates, used and free space, top processes by disk I/O
- **Network**: download and upload rates, totals since boot, and per-interface rates, Wi-Fi signal, IP addresses and gateway

Data comes from `ksystemstats`, the same service used by Plasma System Monitor.

## Requirements

- Plasma 6.0 or later
- `ksystemstats` and the `org.kde.ksysguard` QML modules (installed with Plasma System Monitor on most distributions)

## Install

```sh
git clone <repository-url>
cd plasma-system-stats
kpackagetool6 -t Plasma/Applet -i package
```

Then right-click the panel, choose **Add Widgets…** and add **System Stats**.

To update after pulling changes:

```sh
kpackagetool6 -t Plasma/Applet -u package
```

Plasma may cache the old version. If changes do not show up, restart the shell with `systemctl --user restart plasma-plasmashell`.

To remove:

```sh
kpackagetool6 -t Plasma/Applet -r in.amritanshu.systemstats
```

## Settings

- Choose which modules appear in the panel (the popup always shows all of them)
- Compact mode: smaller text, label above the value, no graphs
- Show or hide graphs and labels
- Update interval (1 to 10 seconds)

## Development

Run the widget in its own window without adding it to a panel:

```sh
plasmawindowed in.amritanshu.systemstats
```

`plasmoidviewer` from the `plasma-sdk` package can also be used to test different panel form factors.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
