#!/usr/bin/env bash
# Installer for nf — Note Fast
# https://github.com/YOUR_USERNAME/nf

set -e

REPO="https://raw.githubusercontent.com/YOUR_USERNAME/nf/main"
INSTALL_DIR="/usr/local/bin"
SCRIPT="nf"

echo "Installing nf..."

# Download nf.sh
curl -sL "$REPO/nf.sh" -o "/tmp/nf_install.sh"
chmod +x "/tmp/nf_install.sh"

# Install (try without sudo, fall back to sudo)
if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
else
  echo "Need sudo to install to $INSTALL_DIR"
  sudo mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
fi

echo ""
echo "✓ nf installed successfully!"
echo "  Run: nf \"your first note\""
echo ""
echo "Optional: install fzf for TUI mode"
echo "  Ubuntu/Debian: sudo apt install fzf"
echo "  Arch:          sudo pacman -S fzf"
echo "  Fedora:        sudo dnf install fzf"
