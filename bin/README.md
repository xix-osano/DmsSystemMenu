# System Menu - Scripts Guide

This folder contains helper scripts for the System Menu plugin. These scripts provide functionality for screenshots, screen recording, file sharing, and system controls.

## Scripts

### cmd-screenshot
Take screenshots with region or fullscreen selection.

**Usage:**
```bash
dms-sm-screenshot [mode] [processing]
```

**Modes:**
- `region` - User selects region interactively
- `fullscreen` - Capture entire focused display
- `smart` (default) - Auto-detect based on click

**Processing:**
- `slurp` (default) - Interactive editing with satty
- `direct` - Direct capture without editing

**Dependencies:** `grim`, `slurp`, `wl-copy`

### cmd-screenrecord
Record screen with optional audio and webcam.

**Usage:**
```bash
dms-sm-screenrecord [scope] [--with-audio] [--with-webcam]
```

**Scopes:**
- `region` (default) - User selects region
- `output` - Record full display

**Flags:**
- `--with-audio` - Include system audio
- `--with-webcam` - Include webcam (requires additional setup)

**Dependencies:** `wf-recorder`, `slurp`, `hyprctl` (for Hyprland)

### cmd-share
Share files or clipboard content using LocalSend.

**Usage:**
```bash
dms-sm-share [mode] [files...]
```

**Modes:**
- `clipboard` - Share clipboard content
- `file` - Browse and select files
- `folder` - Browse and select folders

**Dependencies:** `localsend`, `fzf`, `wl-paste` (for Wayland)

### cmd-editor
Launch your preferred editor with a file.

**Features:**
- Respects `$EDITOR` environment variable
- Auto-detects terminal for TUI editors (vim, nvim, nano, etc.)
- Falls back to GUI editors or direct execution
- Supports common terminals: kitty, alacritty, xterm


**Current Implementation:** Toggles hypridle on/off
**Dependencies:** `hypridle`

## Requirements

### Minimal (Core Screenshots)
- `grim` - Screenshot tool for Wayland
- `slurp` - Region selector
- `wl-copy` - Clipboard access

### Recommended (Full Features)
- `grim`, `slurp`, `wl-copy` - Screenshot support
- `wf-recorder` - Screen recording
- `localsend` - File sharing
- `fzf` - File browser for sharing
# System Menu — Scripts Guide

This folder contains helper scripts used by the System Menu plugin. The scripts provide screenshots, screen recording, sharing, package helpers, editor/terminal helpers and other small utilities.

## Installation / Setup

There are two common installation approaches:

1) Use the repository installer (recommended for this project):

```bash
./dms-sm-setup.sh
```

This script copies the scripts from the repository `bin/` folder into `~/.local/share/dms-sm-plugin/bin`, makes them executable and performs a few optional package installs on Arch Linux.

2) Manual install (alternate): copy the `bin/` contents to a directory in your PATH (or to a panel/script directory such as `~/.config/systemMenu/scripts/`) and make them executable:

```bash
mkdir -p ~/.local/share/dms-sm-plugin/bin
cp bin/* ~/.local/share/dms-sm-plugin/bin/
chmod +x ~/.local/share/dms-sm-plugin/bin/*
# or copy to your panel scripts directory
mkdir -p ~/.config/systemMenu/scripts
cp bin/* ~/.config/systemMenu/scripts/
chmod +x ~/.config/systemMenu/scripts/*
```

Make sure the chosen install directory is in your PATH so the plugin or your panel can invoke the helpers.

## Quick usage examples

- Take a screenshot (interactive region/fullscreen):

```bash
dms-sm-screenshot [region|fullscreen|smart] [slurp|direct]
```

- Record the screen (region or full output):

```bash
dms-sm-screenrecord [region|output] [--with-audio] [--with-webcam]
```

- Share files or clipboard via LocalSend:

```bash
dms-sm-share [clipboard|file|folder] [paths...]
```

- Open an editor (respects $EDITOR and prefers TUI editors in a terminal):

```bash
dms-sm-editor [file]
```

## Scripts included (brief)

The `bin/` directory contains the following scripts. Each script offers small helpers intended to be invoked by the UI plugin.

- dms-sm-cmd-missing — report missing commands or dependencies
- dms-sm-editor — open a file in the configured editor
- dms-sm-launch-editor — helper to launch an editor in a terminal
- dms-sm-launch-terminal — open configured terminal
- dms-sm-pkg-add — package helper (add)
- dms-sm-pkg-aur-accessible — check AUR accessibility
- dms-sm-pkg-aur-install — install packages from AUR
- dms-sm-pkg-install — install packages from repos
- dms-sm-pkg-missing — detect missing packages
- dms-sm-pkg-present — check package presence
- dms-sm-pkg-remove — remove package
- dms-sm-present — present a message/notification
- dms-sm-screenrecord — screen recording helper (wf-recorder)
- dms-sm-screenshot — screenshot helper (grim/slurp)
- dms-sm-setup-apparmor — apparmor setup helper
- dms-sm-setup-dns — DNS setup helper
- dms-sm-setup-secureboot — secureboot setup helper
- dms-sm-share — share files/clipboard (localsend)
- dms-sm-show-done — quick done/notification helper
- dms-sm-show-logo — show logo helper
- dms-sm-snapshot — create snapshots (Btrfs / snapper)
- dms-sm-terminal — open terminal helper
- dms-sm-update — update helper orchestration
- dms-sm-update-firmware — firmware update helper
- dms-sm-update-perform — perform update operations
- dms-sm-update-plugin — update plugin helper

For detailed usage of each script (flags and examples) see the project scripts themselves or open an issue requesting expanded documentation for a specific helper.

## Requirements

Minimal (screenshots): `grim`, `slurp`, `wl-copy`.

Recommended (full features): `wf-recorder`, `localsend`, `fzf`, `hyprctl`, `hypridle`, `satty` (annotation), and a terminal emulator such as `kitty` or `alacritty`.

The installer script may attempt package installs on Arch using `pacman` when available; otherwise install the listed dependencies with your distribution's package manager.

## Configuration & environment

Scripts consult environment variables for output locations: `$SCREENSHOT_DIR` / `$XDG_PICTURES_DIR` and `$SCREENRECORD_DIR` / `$XDG_VIDEOS_DIR`. They fall back to `$HOME/Pictures` and `$HOME/Videos` if those are not set.

Adjust the `terminalApp` setting in `SystemMenuSettings.qml` if you want the plugin to use a specific terminal to launch TUI editors.

## Troubleshooting

- Screenshots fail: verify you are on Wayland (`echo $XDG_SESSION_TYPE`) and that `grim`, `slurp` and `wl-copy` are installed.
- Screen recording fails: install `wf-recorder` and confirm `hyprctl` is available for Hyprland.
- Sharing not available: install `localsend` and `fzf`.

## License

These scripts are distributed with the System Menu plugin and follow the same license as the plugin. See project headers or contact the maintainer for specifics.
