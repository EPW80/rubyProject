#!/usr/bin/env bash
# Stop the studioFlow dev stack. Leaves the postgres volume intact.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
docker rm -f rubyapi-dev >/dev/null 2>&1 || true
docker compose stop db
echo "stopped (volume preserved; bundle_cache + db data persist)"
