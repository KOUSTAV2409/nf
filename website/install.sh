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

# --- Tab Completion Setup ---
echo "Setting up tab completion..."
# Bash
if [ -d "/etc/bash_completion.d" ]; then
  curl -sL "$REPO/completions/nf.bash" | sudo tee /etc/bash_completion.d/nf > /dev/null
elif [ -d "/usr/local/etc/bash_completion.d" ]; then
  curl -sL "$REPO/completions/nf.bash" | sudo tee /usr/local/etc/bash_completion.d/nf > /dev/null
fi

# Zsh
ZSH_COMP_DIR="/usr/local/share/zsh/site-functions"
sudo mkdir -p "$ZSH_COMP_DIR"
curl -sL "$REPO/completions/nf.zsh" | sudo tee "$ZSH_COMP_DIR/_nf" > /dev/null

echo ""
echo "✓ nf installed successfully!"
echo "  Run: nf \"your first note\""
echo "  Note: Restart your terminal or run 'source ~/.bashrc' for tab completion."
echo ""
echo "Optional: install fzf for TUI mode (apt install fzf / brew install fzf)"
