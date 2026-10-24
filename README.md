# System Stats

A Plasma 6 widget that shows system usage in the panel, inspired by [Stats](https://github.com/exelban/stats) for macOS.

Each module shows a small graph and its current value. Click a module to open a popup with more detail:

- **CPU**: total usage, user/system/wait split, frequency, temperature, per-core usage and top processes
- **Memory**: used, application, cache, buffers, free, swap and top processes
- **Disk**: read and write rates, used and free space, usage per volume (duplicates hidden) and top processes by disk I/O
- **Network**: download and upload rates, totals since boot, and per-interface rates, Wi-Fi signal, IP addresses and gateway, and optionally the public IP address
- **Sensors**: temperature history, all temperature sensors grouped by chip with readable names, and fan speeds
- **Battery**: level, charging status, time remaining, power draw, charge, health and design capacity (only shown when a battery is present)

Data comes from `ksystemstats`, the same service used by Plasma System Monitor.

## Requirements

- Plasma 6.0 or later
- `ksystemstats` and the `org.kde.ksysguard` QML modules (installed with Plasma System Monitor on most distributions)

## Install

### From a release

Download the `.plasmoid` file from the [latest release](https://github.com/amritanshu-pandey/plasma-system-stats-widget/releases/latest) and install it:

```sh
kpackagetool6 -t Plasma/Applet -i system-stats-*.plasmoid
```

To update, use `-u` instead of `-i` with the newer file.

### From source

```sh
git clone https://github.com/amritanshu-pandey/plasma-system-stats-widget.git
cd plasma-system-stats-widget
make install
```

`make install` also updates an existing installation. Building translations needs `msgfmt` from gettext.

Then right-click the panel, choose **Add Widgets…** and add **System Stats**.

Plasma keeps the old version loaded after an update. Restart the shell to load the new one with `systemctl --user restart plasma-plasmashell`.

To remove:

```sh
kpackagetool6 -t Plasma/Applet -r in.amritanshu.systemstats
```

## Settings

- Choose which modules appear in the panel and their order (the popup always shows all of them)
- Compact mode: smaller text, label above the value, no graphs
- Vertical panels always use the compact layout, with short rates like `860K`, and text shrinks to fit the panel width
- Show or hide graphs and labels
- Space between panel modules, and padding between modules and the panel edges (text shrinks to fit)
- Temperature sensor shown in the panel (CPU average, CPU maximum or any detected sensor)
- Network speed in bits or bytes per second
- Public IP address (off by default; asks api.ipify.org while the Network tab is open, at most every 10 minutes)
- Update interval (1 to 10 seconds)

## Development

| Command | What it does |
|---|---|
| `make install` | Install or update the widget for the current user |
| `make lint` | Check the QML with `qmllint` |
| `make pot` | Update the translation template in `po/` |
| `make plasmoid` | Build `build/system-stats-<version>.plasmoid` |

`make lint` needs `qmllint` from the Qt 6 declarative development tools (`qt6-qtdeclarative-devel` on Fedora, `qt6-declarative-dev-tools` on Debian and Ubuntu).

Run the widget in its own window without adding it to a panel:

```sh
plasmawindowed in.amritanshu.systemstats
```

`plasmoidviewer` from the `plasma-sdk` package can also be used to test different panel form factors.

CI runs `make lint`, checks that the translation template is up to date and builds the `.plasmoid` for every push and pull request. Pushing a `v*` tag publishes a GitHub release with the `.plasmoid` attached.

## Translations

Translations live in `po/`. See [po/README.md](po/README.md) for how to add or update one.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
