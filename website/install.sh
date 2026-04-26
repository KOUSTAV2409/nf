#!/usr/bin/env bash
# Installer for nf — Note Fast
# https://github.com/KOUSTAV2409/nf

set -e

REPO="https://raw.githubusercontent.com/KOUSTAV2409/nf/main"
INSTALL_DIR="/usr/local/bin"
SCRIPT="nf"

echo "Installing nf..."

# Download nf.sh
curl -sL "$REPO/nf.sh" -o "/tmp/nf_install.sh"
chmod +x "/tmp/nf_install.sh"

# Install nf.sh
if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
else
  echo "Need sudo to install to $INSTALL_DIR"
  sudo mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
fi

# --- Tab Completion Setup (The "Bulletproof" Way) ---
echo "Setting up tab completion..."
COMP_DIR="$HOME/.local/share/nf/completions"
mkdir -p "$COMP_DIR"
curl -sL "$REPO/completions/nf.bash" -o "$COMP_DIR/nf.bash"
curl -sL "$REPO/completions/nf.zsh" -o "$COMP_DIR/nf.zsh"

# Add to .bashrc
if [ -f "$HOME/.bashrc" ]; then
  if ! grep -q "nf.bash" "$HOME/.bashrc"; then
    echo -e "\n# nf tab completion\n[ -f \"$COMP_DIR/nf.bash\" ] && source \"$COMP_DIR/nf.bash\"" >> "$HOME/.bashrc"
  fi
fi

# Add to .zshrc
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "nf.zsh" "$HOME/.zshrc"; then
    echo -e "\n# nf tab completion\n[ -f \"$COMP_DIR/nf.zsh\" ] && source \"$COMP_DIR/nf.zsh\"" >> "$HOME/.zshrc"
  fi
fi

echo ""
echo "✓ nf installed successfully!"
echo "  Run: nf \"your first note\""
echo "  Note: Close and REOPEN your terminal to activate tab completion."
echo ""
echo "Optional: install fzf for TUI mode (apt install fzf / brew install fzf)"
