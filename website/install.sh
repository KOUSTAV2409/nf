#!/usr/bin/env bash
# Installer for nf — Note Fast
# https://github.com/KOUSTAV2409/nf

set -euo pipefail

REPO="https://raw.githubusercontent.com/KOUSTAV2409/nf/main"
INSTALL_DIR="/usr/local/bin"
SCRIPT="nf"
SKIP_COMPLETION=false

for arg in "$@"; do
  case "$arg" in
    --no-completion) SKIP_COMPLETION=true ;;
    -h|--help)
      echo "Usage: install.sh [--no-completion]"
      echo "  --no-completion  Do not download completions or edit shell rc files"
      exit 0
      ;;
  esac
done

echo "Installing nf..."

curl -sL "$REPO/nf.sh" -o "/tmp/nf_install.sh"
chmod +x "/tmp/nf_install.sh"

if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
else
  echo "Need sudo to install to $INSTALL_DIR"
  sudo mv "/tmp/nf_install.sh" "$INSTALL_DIR/$SCRIPT"
fi

setup_completion() {
  echo "Setting up tab completion..."
  local comp_dir="$HOME/.local/share/nf/completions"
  mkdir -p "$comp_dir"
  curl -sL "$REPO/completions/nf.bash" -o "$comp_dir/nf.bash"
  curl -sL "$REPO/completions/nf.zsh" -o "$comp_dir/nf.zsh"

  if [ -f "$HOME/.bashrc" ] && ! grep -q "nf.bash" "$HOME/.bashrc"; then
    echo -e "\n# nf tab completion\n[ -f \"$comp_dir/nf.bash\" ] && source \"$comp_dir/nf.bash\"" >> "$HOME/.bashrc"
  fi

  if [ -f "$HOME/.zshrc" ] && ! grep -q "nf.zsh" "$HOME/.zshrc"; then
    echo -e "\n# nf tab completion\n[ -f \"$comp_dir/nf.zsh\" ] && source \"$comp_dir/nf.zsh\"" >> "$HOME/.zshrc"
  fi
}

if [ "$SKIP_COMPLETION" = false ]; then
  if [ -t 0 ]; then
    read -rp "Add tab completion to your shell config (.bashrc / .zshrc)? [Y/n] " answer
    case "$answer" in
      n|N|no|No|NO) SKIP_COMPLETION=true ;;
    esac
  fi
fi

if [ "$SKIP_COMPLETION" = false ]; then
  setup_completion
else
  echo "Skipped tab completion setup."
fi

echo ""
echo "✓ nf installed successfully!"
echo "  Run: nf \"your first note\""
if [ "$SKIP_COMPLETION" = false ]; then
  echo "  Note: Close and REOPEN your terminal to activate tab completion."
fi
echo ""
echo "Optional: install fzf for TUI mode (apt install fzf / brew install fzf)"
