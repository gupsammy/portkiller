<table>
<tr>
<td width="140" valign="top">
<img src="assets/app-logo-color.png" alt="PortKiller" width="120">
</td>
<td valign="middle">
<h1>PortKiller</h1>
<p><em>Stop hunting. Start killing.</em><br>
That rogue process hogging port 3000? Gone in one click.</p>
<a href="https://github.com/gupsammy/PortKiller/releases/download/v0.1.5/PortKiller.dmg">
<img src="https://img.shields.io/badge/⬇_Download_v0.1.5-22c55e?style=for-the-badge&logoColor=white" alt="Download v0.1.5">
</a>
&nbsp;
<img src="https://img.shields.io/badge/macOS_10.15+-555?style=flat-square" alt="Platform">
<img src="https://img.shields.io/badge/MIT-555?style=flat-square" alt="License">
</td>
</tr>
</table>

Every developer knows the drill: `lsof -i :3000`, squint at the output, find the PID, `kill -9 1234`, repeat. PortKiller lives in your menu bar and does all that for you. One click. Done.

---

## Features

- **One-Click Process Termination** — Kill any process hogging your dev ports instantly from the menu bar
- **Docker Integration** — See which containers are using ports and stop them directly
- **Homebrew Services** — Detect and stop brew services (PostgreSQL, Redis, MySQL) without touching the terminal
- **Desktop Notifications** — Get notified when new processes start listening on your ports
- **Project Detection** — Shows which git project each process belongs to
- **Smart Graceful Shutdown** — SIGTERM first, SIGKILL only if needed
- **Native Menu Bar App** — Lightweight, adapts to light/dark mode, zero resource usage when idle
- **Pre-configured for Dev Ports** — Monitors Node.js, React, Vite, Django, Flask, PostgreSQL, Redis, MongoDB, and more out of the box
- **Fully Configurable** — Add or remove port ranges via simple JSON config

## Installation

### Download (Recommended)

1. Download **[PortKiller.dmg](https://github.com/gupsammy/PortKiller/releases/download/v0.1.5/PortKiller.dmg)**
2. Open the DMG and drag PortKiller to Applications
3. Launch from Applications or Spotlight

The app appears in your menu bar — click to see active port listeners.

### Build from Source

```bash
git clone https://github.com/gupsammy/PortKiller.git
cd PortKiller
cargo build --release
./target/release/portkiller
```

Requires Rust 1.85+ (2024 edition).

## Configuration

PortKiller creates `~/.portkiller.json` on first run. Edit via the menu bar (Edit Configuration) or directly:

```json
{
  "monitoring": {
    "poll_interval_secs": 2,
    "port_ranges": [[3000, 3010], [5432, 5432], [8080, 8090]],
    "show_project_names": true
  },
  "integrations": {
    "brew_enabled": true,
    "docker_enabled": true
  },
  "notifications": {
    "enabled": true
  },
  "system": {
    "launch_at_login": false
  }
}
```

Changes require an app restart.

## Uninstall

1. Quit PortKiller from the menu bar
2. Move PortKiller.app from Applications to Trash
3. Optionally: `rm ~/.portkiller.json`

## Platform Support

**macOS 10.15 (Catalina) and later** — Intel and Apple Silicon

## Development

```bash
# Debug build with logging
RUST_LOG=debug cargo run

# Code quality
cargo fmt && cargo clippy

# Install pre-commit hook (auto-formats on commit)
./scripts/install-hooks.sh
```

## Feature Requests & Bug Reports

Have an idea or found a bug? [Open an issue](https://github.com/gupsammy/PortKiller/issues) — contributions welcome!

## License

MIT License — do whatever you want with it.

## Acknowledgments

Built with [tray-icon](https://github.com/tauri-apps/tray-icon), [winit](https://github.com/rust-windowing/winit), and [nix](https://github.com/nix-rust/nix).

---

<p align="center"><em>Made for developers who have better things to do than hunt PIDs</em></p>
