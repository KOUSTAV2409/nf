#!/bin/bash
set -euo pipefail

# Define build directory and output package name
BUILD_DIR="build_deb_temp"
VERSION="0.3.4"
DEB_NAME="nf_${VERSION}_all.deb"

echo "Building Debian package for nf v${VERSION}..."

# Cleanup any previous builds
rm -rf "$BUILD_DIR" "$DEB_NAME"

# Create Debian directory structure
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/bash-completion/completions"

# Copy main binary script
cp nf.sh "$BUILD_DIR/usr/bin/nf"
chmod 755 "$BUILD_DIR/usr/bin/nf"

# Copy completion script if present
if [ -f "completions/nf.bash" ]; then
  cp completions/nf.bash "$BUILD_DIR/usr/share/bash-completion/completions/nf"
  chmod 644 "$BUILD_DIR/usr/share/bash-completion/completions/nf"
fi

# Copy Debian packaging control files
cp debian/control "$BUILD_DIR/DEBIAN/control"

if [ -f "debian/postinst" ]; then
  cp debian/postinst "$BUILD_DIR/DEBIAN/postinst"
  chmod 755 "$BUILD_DIR/DEBIAN/postinst"
fi

if [ -f "debian/postrm" ]; then
  cp debian/postrm "$BUILD_DIR/DEBIAN/postrm"
  chmod 755 "$BUILD_DIR/DEBIAN/postrm"
fi

# Build the debian package
dpkg-deb --build "$BUILD_DIR" "$DEB_NAME"

# Cleanup build directory
rm -rf "$BUILD_DIR"

echo "Successfully built package: $DEB_NAME"
