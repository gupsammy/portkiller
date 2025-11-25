# PortKiller

A lightweight macOS menu bar application that monitors common development server ports and allows you to quickly kill processes listening on those ports.

![PortKiller Icon](https://img.shields.io/badge/platform-macOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Real-time Port Monitoring** - Automatically scans and displays processes listening on development ports
- **Native Menu Bar Icon** - Adapts to light/dark mode automatically
- **Quick Kill** - Terminate individual processes or all at once with a single click
- **Graceful Shutdown** - Attempts SIGTERM first, falls back to SIGKILL if needed
- **Configurable Ports** - Easily customize which ports to monitor via JSON config file
- **Native Performance** - Built with Rust for minimal resource usage

## Default Monitored Ports

- **3000-3010** - Node.js, React, Next.js, Vite
- **3306** - MySQL
- **4000-4010** - Alternative Node servers
- **5001-5010** - Flask, general dev servers
- **5173** - Vite default
- **5432** - PostgreSQL
- **6379** - Redis
- **8000-8100** - Django, Python HTTP servers
- **8080-8090** - Tomcat, alternative HTTP
- **9000-9010** - Various dev tools
- **27017** - MongoDB

## Installation

### Download DMG (Recommended)

1. Download the latest `PortKiller.dmg` from the [Releases](https://github.com/gupsammy/PortKiller/releases) page
2. Open the DMG file
3. Drag PortKiller to your Applications folder
4. Launch PortKiller from Applications or Spotlight

The app will appear in your macOS menu bar and is ready to use!

### Build from Source

```bash
# Clone the repository
git clone https://github.com/gupsammy/PortKiller.git
cd portkiller

# Build in release mode
cargo build --release

# Run the application
./target/release/portkiller
```

## Configuration

PortKiller creates a configuration file at `~/.portkiller.json` on first run. You can edit this file to customize which ports to monitor.

To edit the configuration:
1. Click the PortKiller icon in your menu bar
2. Select "Edit Configuration..."
3. Modify the port ranges as needed
4. Save and restart PortKiller

Example configuration:
```json
{
  "monitoring": {
    "poll_interval_secs": 2,
    "port_ranges": [
      [3000, 3010],
      [5432, 5432],
      [8080, 8090]
    ],
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

## Usage

1. Launch the application - it will appear in your macOS menu bar
2. The icon automatically adapts to your menu bar appearance (light/dark mode)
3. Click the menu bar icon to see all active port listeners
4. Select a process to terminate it, or use "Kill all" to terminate all at once

## Uninstall

1. Quit PortKiller from the menu bar (click icon → Quit)
2. Move PortKiller from Applications to Trash
3. Optionally remove the config file: `rm ~/.portkiller.json`

## Platform Support

**macOS** - Fully supported ✅

**Linux** - Partially compatible (requires manual config file editing, `lsof` and `ps` commands must be available)

**Windows** - Not supported (relies on Unix-specific tools and signals)

## Development

### Prerequisites

- Rust 1.70 or later
- macOS (for full functionality)

### Building

```bash
# Build in debug mode
cargo build

# Build in release mode (optimized)
cargo build --release

# Run with debug logging
RUST_LOG=debug cargo run

# Check code without building
cargo check

# Format code
cargo fmt

# Run linter
cargo clippy
```

### Architecture

PortKiller uses a multi-threaded event-driven architecture:

- **Main Event Loop** - Manages UI and orchestrates state changes
- **Monitor Thread** - Polls ports every 2 seconds using `lsof`
- **Menu Listener Thread** - Handles user interactions
- **Kill Worker Thread** - Executes process termination with graceful shutdown

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Contributing

Contributions are welcome! Here are some ways you can help:

- Report bugs and request features via [Issues](https://github.com/gupsammy/PortKiller/issues)
- Submit pull requests for bug fixes or new features
- Improve documentation
- Share your experience and spread the word

Please ensure your code follows the existing style and passes `cargo clippy` and `cargo fmt` checks.

## License

MIT License - feel free to use this project however you'd like!

## Acknowledgments

Built with:
- [tray-icon](https://github.com/tauri-apps/tray-icon) - Cross-platform system tray
- [winit](https://github.com/rust-windowing/winit) - Window and event loop
- [nix](https://github.com/nix-rust/nix) - Unix signal handling

---

**Made with ❤️ for developers who are tired of manually killing port listeners**
