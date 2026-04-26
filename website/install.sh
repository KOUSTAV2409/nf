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
BASH_COMP_DIR=""
for dir in "/etc/bash_completion.d" "/usr/local/etc/bash_completion.d"; do
  if [ -d "$dir" ]; then BASH_COMP_DIR="$dir"; break; fi
done

if [ -n "$BASH_COMP_DIR" ]; then
  curl -sL "$REPO/completions/nf.bash" | sudo tee "$BASH_COMP_DIR/nf" > /dev/null
fi

# Zsh
ZSH_COMP_DIR=""
for dir in "/usr/local/share/zsh/site-functions" "/usr/share/zsh/site-functions" "/usr/share/zsh/vendor-completions"; do
  if [ -d "$dir" ]; then ZSH_COMP_DIR="$dir"; break; fi
done

if [ -n "$ZSH_COMP_DIR" ]; then
  sudo mkdir -p "$ZSH_COMP_DIR"
  curl -sL "$REPO/completions/nf.zsh" | sudo tee "$ZSH_COMP_DIR/_nf" > /dev/null
else
  # If no system dir, suggest local source
  echo "  Note: System completion folder not found. Adding to ~/.zshrc..."
  grep -q "nf.zsh" ~/.zshrc 2>/dev/null || echo "source <(curl -sL $REPO/completions/nf.zsh)" >> ~/.zshrc
fi

echo ""
echo "✓ nf installed successfully!"
echo "  Run: nf \"your first note\""
echo "  Note: Restart your terminal or run 'source ~/.bashrc' for tab completion."
echo ""
echo "Optional: install fzf for TUI mode (apt install fzf / brew install fzf)"
