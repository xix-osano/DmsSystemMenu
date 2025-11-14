#!/bin/bash

# SystemMenu Plugin Installation Script
# This script copies helper scripts to ~/.local/bin and makes them executable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
INSTALL_DIR="$HOME/.local/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}SystemMenu Plugin Installation${NC}"
echo "========================================"
echo ""

# Check if bin directory exists
if [[ ! -d "$BIN_DIR" ]]; then
    echo -e "${RED}✗ Error: bin directory not found at $BIN_DIR${NC}"
    exit 1
fi

# Create ~/.local/bin if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}→${NC} Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠ Warning: $INSTALL_DIR is not in your PATH${NC}"
    echo "  Add it to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Count scripts
SCRIPT_COUNT=$(ls "$BIN_DIR" 2>/dev/null | wc -l)
echo -e "${YELLOW}→${NC} Found $SCRIPT_COUNT scripts to install"
echo ""

# Copy scripts
COPIED=0
FAILED=0

for script in "$BIN_DIR"/*; do
    if [[ -f "$script" ]]; then
        SCRIPT_NAME=$(basename "$script")
        
        # Copy file
        if cp "$script" "$INSTALL_DIR/$SCRIPT_NAME" 2>/dev/null; then
            # Make executable
            chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
            echo -e "${GREEN}✓${NC} Installed: $SCRIPT_NAME"
            ((COPIED++))
        else
            echo -e "${RED}✗${NC} Failed to install: $SCRIPT_NAME"
            ((FAILED++))
        fi
    fi
done

echo ""
echo "========================================"
echo -e "${GREEN}Installation Summary${NC}"
echo "  Installed: $COPIED scripts"
if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}  Failed: $FAILED scripts${NC}"
fi
echo ""

# Verify installation
echo -e "${YELLOW}→${NC} Verifying installation..."
VERIFIED=0
for script in "$BIN_DIR"/*; do
    if [[ -f "$script" ]]; then
        SCRIPT_NAME=$(basename "$script")
        if [[ -x "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
            ((VERIFIED++))
        fi
    fi
done

if [[ $VERIFIED -eq $COPIED ]]; then
    echo -e "${GREEN}✓ All scripts verified as executable${NC}"
    echo ""
    echo "Installation complete! The SystemMenu plugin helper scripts are ready."
    echo "Restart your panel or reload the plugin to apply changes."
    exit 0
else
    echo -e "${RED}✗ Some scripts failed verification${NC}"
    exit 1
fi
