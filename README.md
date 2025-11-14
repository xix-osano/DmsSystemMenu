# System Menu Widget

A compact system menu widget for the Quickshell/DMS panel providing native popup menus for common system tasks, settings, installation, and utilities. No external walker UI required — all menu interactions happen within the panel.

## Features

- **Native popup menu** — stack-driven menu UI built into the widget
- **Helper script support** — executes system utilities from `bin/` directory:
  - Screenshots and screen recording
  - File/clipboard sharing via LocalSend
  - Editor launching
  - System lock/screensaver/suspend/reboot
  - Package management (pacman/AUR)
  - Config updates and restarts
  - And many more...
- **Service-based architecture** — `SystemMenuService.qml` provides high-level wrappers and safe command execution

## Installation

### 1. Copy Plugin to DMS

```bash
# Copy to your DMS plugins directory
cp -r /path/to/dms-system-menu ~/.config/DankMaterialShell/plugins/SystemMenu
```

### 2. Install Helper Scripts

Run the installation script to copy all helpers to `$HOME/.local/bin`:

```bash
cd ~/.config/DankMaterialShell/plugins/SystemMenu
bash install.sh
```

This will:
- Create `$HOME/.local/bin` if it doesn't exist
- Copy all scripts from `bin/` directory
- Make them executable
- Verify installation

**Important:** Ensure `$HOME/.local/bin` is in your shell's `$PATH`. Add this to your shell profile (e.g., `~/.bashrc`, `~/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Reload Panel

Restart your panel process to load the plugin:

```bash
# Restart DMS panel
systemctl --user restart dms
# or
pkill dms && dms &
```

## Architecture

### Key Files

- **SystemMenuWidget.qml** — Main widget component; handles menu UI and dispatch logic
- **SystemMenuService.qml** — Singleton service providing safe command execution wrappers
- **SystemMenuSettings.qml** — Settings UI for widget configuration
- **bin/** — Helper scripts (shellos-* commands)
- **install.sh** — Installation script to set up helpers in `$HOME/.local/bin`

### Service Wrappers

`SystemMenuService` provides type-safe methods for common operations:

```qml
SystemMenuService.takeScreenshot(mode, processing)    // "smart"|"region"|"fullscreen"
SystemMenuService.screenrecord(scope, withAudio, withWebcam)
SystemMenuService.share(mode)                         // "clipboard"|"file"|"folder"
SystemMenuService.launchEditor(path)
SystemMenuService.lockScreen()
SystemMenuService.runUpdate()
SystemMenuService.launchScreensaver(force)
// and more...
```

## Requirements

- **Quickshell** panel runtime with QML support
- **Qt 6.0+** with QtQuick.Controls
- **Helper scripts** installed via `install.sh` (see Installation above)
- **System tools** — scripts depend on: `grim`, `slurp`, `hyprctl`, `jq`, `kitty`, `systemd-run`, `notify-send`, etc.
- **PATH setup** — `$HOME/.local/bin` must be in the panel process's PATH

## Troubleshooting

### Scripts not found

**Problem:** Menu actions fail silently or log "command not found"

**Solution:**
1. Verify installation: `ls -la $HOME/.local/bin/shellos-*`
2. Check PATH: `echo $PATH | grep ".local/bin"`
3. Restart panel after adding to PATH
4. Ensure panel is restarted, not just reloaded

### Menu doesn't appear

**Problem:** Clicking the System pill does nothing

**Solution:**
1. Check panel logs: `journalctl --user -u dms -f`
2. Verify plugin is loaded: check DMS plugin directory
3. Restart panel: `systemctl --user restart dms`

### Helper not working

**Problem:** Specific helper command fails (e.g., screenshot doesn't work)

**Solution:**
1. Test manually: `shellos-cmd-screenshot smart slurp`
2. Check for missing dependencies: `which grim slurp hyprctl jq`
3. Review helper script: `cat $HOME/.local/bin/shellos-cmd-screenshot`
4. Check system logs: `journalctl -xe`

## Development

### Running Tests

A smoke-test file is provided to validate service functions:

```bash
# Load SystemMenuServiceTest.qml in a QML viewer
qml6 SystemMenuServiceTest.qml
```

### Adding New Menu Items

Edit `mainMenu` in `SystemMenuWidget.qml`:

```qml
{ text: "My Action", icon: "icon_name", actionCmd: "command-to-run" }
```

Or use service wrappers in the dispatch logic.

## Changelog

### v1.0.0 (Nov 14, 2025)

- Migrated from external `systemmenu.sh` walker script to native QML menu
- Implemented `SystemMenuService` singleton for safe command execution
- Added installation script (`install.sh`) for easy setup
- Full plugin compatibility with DMS/Quickshell architecture
- Refactored menu dispatch to use typed service methods

---

**Author:** Enosh Osano Misonge  
**License:** See LICENSE file  
**Generated:** November 14, 2025

