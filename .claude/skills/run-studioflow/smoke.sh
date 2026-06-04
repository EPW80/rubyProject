#!/usr/bin/env bash
# Drive the running studioFlow API end-to-end via curl.
# Asserts HTTP codes and a few body invariants. Exits non-zero on first failure.
set -euo pipefail

BASE=${BASE:-http://localhost:3000}
EMAIL=${EMAIL:-smoke+$(date +%s)@example.com}
PASS=${PASS:-password123}
H=$(mktemp)
trap "rm -f $H" EXIT

expect() {
  local label=$1 want=$2 got=$3
  if [ "$got" != "$want" ]; then
    echo "✗ $label: expected $want, got $got" >&2
    exit 1
  fi
  echo "✓ $label → $got"
}

echo "→ signup ($EMAIL)"
code=$(curl -sS -D "$H" -o /tmp/r.json -w '%{http_code}' -X POST "$BASE/api/v1/signup" \
  -H 'Content-Type: application/json' \
  -d "{\"user\":{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"name\":\"Smoke\"}}")
expect "POST /signup" 201 "$code"
TOKEN=$(grep -i '^authorization' "$H" | sed 's/^[Aa]uthorization: //I' | tr -d '\r\n')
[ -n "$TOKEN" ] || { echo "✗ no Authorization header on signup"; exit 1; }
echo "✓ JWT received"

echo "→ unauth list"
code=$(curl -sS -o /dev/null -w '%{http_code}' "$BASE/api/v1/projects")
expect "GET /projects (unauth)" 401 "$code"

echo "→ auth list (empty)"
code=$(curl -sS -o /tmp/r.json -w '%{http_code}' "$BASE/api/v1/projects" -H "Authorization: $TOKEN")
expect "GET /projects (auth)" 200 "$code"
grep -q '"total":0' /tmp/r.json || { echo "✗ expected total:0, got:"; cat /tmp/r.json; exit 1; }
echo "✓ pagy meta total=0"

echo "→ create project"
code=$(curl -sS -o /tmp/r.json -w '%{http_code}' -X POST "$BASE/api/v1/projects" \
  -H "Authorization: $TOKEN" -H 'Content-Type: application/json' \
  -d '{"project":{"name":"Smoke Project","client":"Acme","description":"e2e","status":"backlog"}}')
expect "POST /projects" 201 "$code"
PID=$(grep -oE '"id":"[0-9]+"' /tmp/r.json | head -1 | grep -oE '[0-9]+')
[ -n "$PID" ] || { echo "✗ no id in create response"; cat /tmp/r.json; exit 1; }
echo "✓ created project id=$PID"

echo "→ update_status to active"
code=$(curl -sS -o /tmp/r.json -w '%{http_code}' -X PATCH "$BASE/api/v1/projects/$PID/update_status" \
  -H "Authorization: $TOKEN" -H 'Content-Type: application/json' \
  -d '{"status":"active"}')
expect "PATCH /projects/$PID/update_status" 200 "$code"
grep -q '"status":"active"' /tmp/r.json || { echo "✗ status not active:"; cat /tmp/r.json; exit 1; }

echo "→ activity log"
code=$(curl -sS -o /tmp/r.json -w '%{http_code}' "$BASE/api/v1/projects/$PID/activity" -H "Authorization: $TOKEN")
expect "GET /projects/$PID/activity" 200 "$code"
grep -q '"action":"created"' /tmp/r.json || { echo "✗ no 'created' action in activity"; cat /tmp/r.json; exit 1; }
grep -q '"action":"status_changed"' /tmp/r.json || { echo "✗ no 'status_changed' action"; cat /tmp/r.json; exit 1; }
echo "✓ activity has 'created' + 'status_changed'"

echo "→ logout"
code=$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE "$BASE/api/v1/logout" -H "Authorization: $TOKEN")
expect "DELETE /logout" 200 "$code"

echo "→ revoked token rejected"
code=$(curl -sS -o /dev/null -w '%{http_code}' "$BASE/api/v1/projects" -H "Authorization: $TOKEN")
expect "GET /projects (revoked)" 401 "$code"

echo
echo "all smoke checks passed"
