# macport

macOS menu bar app for monitoring and killing processes on development ports. Built with Rust and native system tray integration.

## Tech Stack

**Language:** Rust 2024 edition
**Package Manager:** Cargo
**Key Dependencies:** tray-icon, winit, nix, crossbeam-channel, anyhow

## Development Commands

```bash
# Run with debug logging
RUST_LOG=debug cargo run

# Build release binary
cargo build --release

# Code quality
cargo fmt              # Format code
cargo clippy           # Lint
cargo check            # Quick compile check

# Install git hooks (auto-format on commit)
./scripts/install-hooks.sh
```

## Helper Scripts

The `scripts/` directory contains utilities for development and testing:

- **install-hooks.sh**: Installs git pre-commit hook for automatic code formatting
- **start-test-ports.sh**: Spawns test processes on various ports for development testing
- **test-notifications.sh**: Tests macOS notification functionality

## Configuration

User config stored at `~/.macport.json` (auto-created on first run):

```json
{
  "port_ranges": [[3000, 3010], [5432, 5432], ...],
  "inactive_color": [255, 255, 255],    // Menu bar icon when idle
  "active_color": [255, 69, 58],        // Icon when ports active
  "notifications_enabled": true
}
```

Edit via menu: **Edit Configuration** opens in default text editor.

## Architecture

### Single-File Design
Entire app lives in `src/main.rs` (~1286 lines). Intentional simplicity for a focused utility.

### Threading Model
Four concurrent threads communicate via channels and event loop proxy:

1. **Main Loop** (winit): UI events, tray updates, state orchestration
2. **Monitor Thread**: Polls ports every 2s using `lsof`, detects Docker containers via `docker ps`, sends `ProcessesUpdated` events
3. **Menu Listener**: Converts menu clicks to `MenuAction` events
4. **Kill Worker**: Executes termination commands (process kill, Docker stop, Homebrew stop)

### State Management
`AppState` tracks:
- Active processes (`ProcessInfo`: port, pid, command)
- Docker containers mapped to ports (`docker_port_map`)
- Project metadata cache (git repo detection for context)
- Last action feedback (shown in tooltip)
- Snooze state (temporarily disable monitoring)

### Process Termination
Graceful shutdown sequence in `terminate_pid`:
1. Check existence (`kill(pid, None)`)
2. SIGTERM → wait 2s (polls every 200ms)
3. SIGKILL → wait 1s (if still alive)
4. Return outcome: Success, AlreadyExited, PermissionDenied, TimedOut, Failed

### Menu Actions
- **Kill [process]**: Terminate specific PID
- **Kill all**: Terminate all monitored processes
- **Stop [docker container]**: `docker stop <container>`
- **Stop [brew service]**: `brew services stop <service>`
- **Snooze 30m**: Pause monitoring temporarily
- **Edit Configuration**: Open `~/.macport.json` in text editor
- **Quit**: Exit app

### Platform Integration
- Uses `lsof` for port detection (macOS/Unix)
- Uses `ps` for process name resolution
- Uses `osascript` for native macOS notifications
- Icon is template-based (auto-adapts to light/dark mode)
- Dynamic icon coloring based on config

## Default Port Ranges

```rust
(3000, 3010)   // Node.js, React, Next.js, Vite
(3306, 3306)   // MySQL
(4000, 4010)   // Alternative Node servers
(5001, 5010)   // Flask, dev servers (5000 excluded - macOS AirPlay)
(5173, 5173)   // Vite
(5432, 5432)   // PostgreSQL
(6379, 6379)   // Redis
(8000, 8100)   // Django, Python
(8080, 8090)   // Tomcat, alt HTTP
(9000, 9010)   // Dev tools
(27017, 27017) // MongoDB
```

Note: Port 5000 excluded to avoid conflicts with macOS AirPlay Receiver.

## Key Constants

```rust
POLL_INTERVAL = 2s           // Monitor frequency
SIGTERM_GRACE = 2s           // Before SIGKILL
SIGKILL_GRACE = 1s           // Final grace period
POLL_STEP = 200ms            // Process check granularity
MAX_TOOLTIP_ENTRIES = 5      // Max displayed in tooltip
```

## Common Patterns

### Adding a monitored port range
Edit `~/.macport.json` via menu or directly. Changes require restart.

### Docker integration
App auto-detects Docker containers exposing ports, displays container names in menu, allows stopping containers instead of killing host processes.

### Notification behavior
Controlled by `notifications_enabled` in config. Uses macOS `osascript` for native notifications on kills/errors.

### Debugging port detection
Run with `RUST_LOG=debug cargo run` to see `lsof` output parsing and Docker container detection.

## Development Notes

- Pre-commit hook auto-formats code (install with `./scripts/install-hooks.sh`)
- Menu IDs use prefixes: `process_`, `docker_stop_`, `brew_stop_` for routing
- Identifiers sanitized to avoid injection (`sanitize_identifier`)
- Icon updates happen on state changes, not on timer
- Project cache prevents repeated git repo lookups for same PIDs
