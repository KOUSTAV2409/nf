#!/usr/bin/env bash
# Assemble website/*.html from shared partials (no npm, no frameworks).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/website-src"
OUT="$ROOT/website"

mkdir -p "$OUT/css"
cp "$SRC/css/site.css" "$OUT/css/site.css"
cp "$SRC/css/launch.css" "$OUT/css/launch.css"
cp "$ROOT/uninstall.sh" "$OUT/uninstall.sh"
chmod +x "$OUT/uninstall.sh"

build_page() {
  local out_file="$1"
  local head_file="$2"
  local body_class="${3:-}"
  local body_file="$4"
  local extra_head="${5:-}"
  local scripts_file="${6:-}"

  {
    printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
    cat "$SRC/pages/$head_file"
    if [ -n "$extra_head" ]; then
      cat "$SRC/pages/$extra_head"
    fi
    printf '%s\n' '</head>'
    if [ -n "$body_class" ]; then
      printf '%s\n' "<body class=\"$body_class\">"
    else
      printf '%s\n' '<body>'
    fi
    cat "$SRC/partials/header.html"
    cat "$SRC/pages/$body_file"
    cat "$SRC/partials/footer.html"
    if [ -n "$scripts_file" ]; then
      cat "$SRC/pages/$scripts_file"
    fi
    printf '%s\n' '</body>' '</html>'
  } > "$OUT/$out_file"
}

# Home: header + sections + footer
build_page "index.html" "index.head.html" "" "index.body.html" "" "index.scripts.html"

# Article pages: shared nav, narrow content column, shared footer
{
  printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
  cat "$SRC/pages/philosophy.head.html"
  printf '%s\n' '</head>' '<body class="page-article">'
  cat "$SRC/partials/header.html"
  printf '%s\n' '  <div class="w">'
  cat "$SRC/pages/philosophy.body.html"
  printf '%s\n' '  </div>'
  cat "$SRC/partials/footer.html"
  printf '%s\n' '</body>' '</html>'
} > "$OUT/philosophy.html"

{
  printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
  cat "$SRC/pages/export-guide.head.html"
  printf '%s\n' '</head>' '<body class="page-article">'
  cat "$SRC/partials/header.html"
  printf '%s\n' '  <div class="w">'
  cat "$SRC/pages/export-guide.body.html"
  printf '%s\n' '  </div>'
  cat "$SRC/partials/footer.html"
  printf '%s\n' '</body>' '</html>'
} > "$OUT/export-guide.html"

# Launch: shared nav + footer, cinematic content in the middle
{
  printf '%s\n' '<!DOCTYPE html>' '<html lang="en">' '<head>'
  cat "$SRC/pages/launch.head.html"
  printf '%s\n' '</head>' '<body class="page-launch">'
  cat "$SRC/partials/header.html"
  cat "$SRC/pages/launch.body.html"
  cat "$SRC/partials/footer.html"
  cat "$SRC/pages/launch.scripts.html"
  printf '%s\n' '</body>' '</html>'
} > "$OUT/launch.html"

echo "Built $OUT/index.html, philosophy.html, export-guide.html, launch.html, and css/"
