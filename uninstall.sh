#!/usr/bin/env bash
# Uninstaller for nf — Note Fast
# https://github.com/KOUSTAV2409/nf

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT="nf"
NF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nf"

echo "Uninstalling nf..."

# Remove the binary
if [ -f "$INSTALL_DIR/$SCRIPT" ]; then
  if [ -w "$INSTALL_DIR" ]; then
    rm "$INSTALL_DIR/$SCRIPT"
  else
    echo "Need sudo to remove from $INSTALL_DIR"
    sudo rm "$INSTALL_DIR/$SCRIPT"
  fi
  echo "✓ Removed $INSTALL_DIR/$SCRIPT"
else
  echo "nf binary not found at $INSTALL_DIR/$SCRIPT (already removed?)"
fi

# Ask about notes data
if [ -d "$NF_DATA_DIR" ]; then
  echo ""
  read -rp "Delete your notes at $NF_DATA_DIR? [y/N] " answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      rm -rf "$NF_DATA_DIR"
      echo "✓ Deleted $NF_DATA_DIR"
      ;;
    *)
      echo "✓ Kept your notes at $NF_DATA_DIR"
      ;;
  esac
fi

echo ""
echo "nf has been uninstalled."
