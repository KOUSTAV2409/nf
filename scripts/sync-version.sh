#!/usr/bin/env bash
# Sync VERSION file into nf.sh, README, and packaging metadata.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"

if [ -z "$VERSION" ]; then
  echo "VERSION file is empty" >&2
  exit 1
fi

sed -i "s/^NF_VERSION=\".*\"/NF_VERSION=\"$VERSION\"/" "$ROOT/nf.sh"
sed -i "s|version-[0-9.]*-blue|version-${VERSION}-blue|" "$ROOT/README.md"
sed -i "s/^pkgver=.*/pkgver=$VERSION/" "$ROOT/PKGBUILD"
sed -i "s|refs/tags/v[0-9.]*\\.tar\\.gz|refs/tags/v${VERSION}.tar.gz|" "$ROOT/Formula/nf.rb"
sed -i "s/^Version: .*/Version: $VERSION/" "$ROOT/debian/control"
sed -i "s/^VERSION=\".*\"/VERSION=\"$VERSION\"/" "$ROOT/build_deb.sh"

echo "Synced version $VERSION"
