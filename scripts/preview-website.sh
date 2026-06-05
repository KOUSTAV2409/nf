#!/usr/bin/env bash
# Preview the site locally. Serves website/ as the root so /css/site.css resolves correctly.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-8080}"

echo "Building website..."
"$ROOT/scripts/build-website.sh"

echo "Preview at http://127.0.0.1:${PORT}/"
echo "Press Ctrl+C to stop."
cd "$ROOT/website"
exec python3 -m http.server "$PORT"
