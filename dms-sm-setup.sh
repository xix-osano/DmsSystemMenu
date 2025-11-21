#!/usr/bin/env bash

# SystemMenu Plugin Installation Script
# This script copies helper scripts to ~/.local/share/dms-sm-plugin/bin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
INSTALL_DIR="$HOME/.local/share/dms-sm-plugin/bin"
LINKING_DIR="$HOME/.local/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} ${YELLOW}SystemMenu Plugin Installation${NC} ${BLUE}      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if bin directory exists
if [[ ! -d "$BIN_DIR" ]]; then
    echo -e "${RED}✗ Error: bin directory not found at $BIN_DIR${NC}"
    echo -e "${RED}  Please ensure the script is run from the plugin directory.${NC}"
    exit 1
fi

# Create ~/.local/share/dms-sm-plugin/bin if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}→${NC} Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" || {
        echo -e "${RED}✗ Failed to create directory${NC}"
        exit 1
    }
    echo -e "${GREEN}✓${NC} Directory created"
else
    echo -e "${GREEN}✓${NC} Directory already exists: $INSTALL_DIR"
fi

# Copy the scripts
echo -e "${YELLOW}→${NC} Copying scripts to $INSTALL_DIR"
if sudo cp -r "$BIN_DIR"/* "$INSTALL_DIR"/ 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Scripts copied successfully"
    # Make scripts executable
    sudo chmod +x "$INSTALL_DIR"/* 2>/dev/null || true
else
    echo -e "${RED}✗ Failed to copy scripts${NC}"
    echo -e "${YELLOW}  Trying without sudo...${NC}"
    if cp -r "$BIN_DIR"/* "$INSTALL_DIR"/ 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Scripts copied successfully (without sudo)"
        chmod +x "$INSTALL_DIR"/* 2>/dev/null || true
    else
        echo -e "${RED}✗ Failed to copy scripts even without sudo${NC}"
        exit 1
    fi
fi

# Link your ~/.local/share/bin/dms-sm-plugin to ~/.local/bin if it exists in PATH
echo "[autolinker] Initiating binary distribution pipeline…"

# Validate source directory
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "[autolinker] Source directory missing: $INSTALL_DIR"
    exit 1
fi

# Ensure target directory exists
if [[ ! -d "$LINKING_DIR" ]]; then
    echo "[autolinker] Creating target directory: $LINKING_DIR"
    mkdir -p "$LINKING_DIR"
fi

# Iterate through all files
for file in "$INSTALL_DIR"/*; do
    name=$(basename "$file")
    link_path="$LINKING_DIR/$name"

    # Skip if already correctly linked
    if [[ -L "$link_path" && "$(readlink "$link_path")" == "$file" ]]; then
        echo "[autolinker] ✔ $name already linked"
        continue
    fi

    # Remove conflicting non-symlink files
    if [[ -e "$link_path" && ! -L "$link_path" ]]; then
        echo "[autolinker] ⚠ Replacing existing file: $link_path"
        rm "$link_path"
    fi

    ln -sf "$file" "$link_path"
    echo "[autolinker] ➜ Linked $name → $link_path"
done

echo "[autolinker] Pipeline complete. Your dms-sm-plugin assets are now operational."


# Install required packages (Arch Linux only)
if command -v pacman >/dev/null 2>&1; then
    echo -e "${YELLOW}→${NC} Installing required packages with pacman (Arch Linux)"
    sudo pacman -S gum inetutils inxi expac less --noconfirm
    sudo pacman -S plocate --noconfirm

    # Try to install localsend if available in pacman
    if pacman -Si localsend >/dev/null 2>&1; then
        echo -e "${YELLOW}→${NC} Installing localsend from pacman"
        sudo pacman -S localsend --noconfirm
    else
        # Try to install localsend-bin from yay if yay is available
        if command -v yay >/dev/null 2>&1; then
            if yay -Si localsend-bin >/dev/null 2>&1; then
                echo -e "${YELLOW}→${NC} Installing localsend-bin from yay"
                yay -S localsend-bin --noconfirm
            else
                echo -e "${YELLOW}⚠${NC} 'localsend-bin' not found in yay. Skipping."
            fi
        else
            echo -e "${YELLOW}⚠${NC} 'yay' not found. Skipping localsend-bin installation."
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC} Skipping package installation: pacman not found. Please install 'gum', 'plocate', and 'localsend' manually if needed."
fi
