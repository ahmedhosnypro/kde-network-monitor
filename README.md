# Network Monitor — KDE Plasma Panel Widget

A minimal, colorized network monitor for the KDE Plasma panel: live upload/download
speeds rendered as `↑ 1.2 MB/s  ↓ 8.4 MB/s` directly in the panel — no popup, no chart,
just the numbers. Built with a **Rust** collector and a **QML** applet.

![preview](https://img.shields.io/badge/Plasma-6.x-blue) ![license](https://img.shields.io/badge/license-MIT-green)

## Features

- **Panel icon style** — sits in the panel like any icon, no popup on click
- **Live rates** — polls `/proc/net/dev` every second, computed by a tiny Rust binary
- **Colorized** — peach (`#F5A97F`) up-arrow + upload, green (`#A6E3A1`) down-arrow + download
- **Zero dependencies** — the collector uses only the Rust standard library
- **Skips loopback/bridges** — ignores `lo`, `docker0`, `virbr0` traffic

## Requirements

- KDE Plasma **6.x** (plasmashell + libplasma)
- Rust toolchain (`rustc`, `cargo`) — to build the collector
- `~/.local/bin` on your `PATH`

## Install

### 1. Build and install the Rust collector

```bash
cd collector-src
cargo build --release
cp target/release/netmon ~/.local/bin/netmon
```

The binary reads `/proc/net/dev`, diffs byte counters against the previous run
(state cached in `~/.cache/com.ahmed.netmon.state`), and prints `up|down` rates
to stdout, e.g. `1.2 MB/s|8.4 MB/s`.

### 2. Install the plasmoid package

```bash
cp -r package ~/.local/share/plasma/plasmoids/com.ahmed.netmon
kbuildsycoca6 2>/dev/null || true
```

### 3. Add it to the panel

Log out and back in (or restart plasmashell: `systemctl --user restart plasma-plasmashell`),
then add **Network Monitor** from the widget explorer onto the panel.

Or via plasmashell scripting:

```bash
qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript '
for (var i in panels()) {
  var p = panels()[i];
  if (p.type === "org.kde.panel") { p.addWidget("com.ahmed.netmon"); }
}'
```

## Layout

```
[↑ 1.2 MB/s   ↓ 8.4 MB/s]
```

- Up arrow + upload value: peach
- Down arrow + download value: green
- Monospace font; font size and width scale with the panel's small icon size

## Customization

Edit `package/contents/ui/main.qml`:

| What | Where |
|---|---|
| Colors | `upColor` / `downColor` properties |
| Font size | `fontSize` factor (`Kirigami.Units.iconSizes.small * 0.85`) |
| Poll interval | `interval: 1000` (ms) in the `DataSource` |
| Skipped interfaces | `SKIP` array in `collector-src/src/main.rs` |

## Project structure

```
network_monitor/
├── package/            # Plasma 6 plasmoid package (QML + metadata)
│   ├── metadata.json
│   └── contents/ui/main.qml
└── collector-src/      # Rust collector
    ├── Cargo.toml
    └── src/main.rs
```

## Troubleshooting

- **Widget shows `--`** — the collector isn't found: verify `~/.local/bin/netmon` exists
  and the full path in `main.qml` (`connectedSources`) matches its location.
- **Widget missing after install** — check `journalctl --user -u plasma-plasmashell | grep netmon`
  for QML errors.
- **After changing interfaces** — delete `~/.cache/com.ahmed.netmon.state` to reset the
  byte-count baseline.

## License

MIT
