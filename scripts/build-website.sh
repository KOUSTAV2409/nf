#!/usr/bin/env bash
# Assemble website/*.html from shared partials (no npm, no frameworks).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/website-src"
OUT="$ROOT/website"

mkdir -p "$OUT/css"
cp "$SRC/css/site.css" "$OUT/css/site.css"
cp "$ROOT/uninstall.sh" "$OUT/uninstall.sh"
chmod +x "$OUT/uninstall.sh"

{
  printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
  cat "$SRC/pages/index.head.html"
  printf '%s\n' '</head>' '<body>'
  cat "$SRC/partials/header-home.html"
  cat "$SRC/pages/index.body.html"
  cat "$SRC/partials/footer.html"
  cat "$SRC/pages/index.scripts.html"
  printf '%s\n' '</body>' '</html>'
} > "$OUT/index.html"

{
  printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
  cat "$SRC/pages/philosophy.head.html"
  printf '%s\n' '</head>' '<body class="page-philosophy">' '<div class="w">'
  cat "$SRC/partials/header-sub.html"
  cat "$SRC/pages/philosophy.body.html"
  cat "$SRC/partials/footer.html"
  printf '%s\n' '</div>' '</body>' '</html>'
} > "$OUT/philosophy.html"

echo "Built $OUT/index.html, $OUT/philosophy.html, and $OUT/css/site.css"
