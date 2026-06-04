#!/usr/bin/env bash
# Launch the studioFlow Rails API in development mode via Docker.
# Idempotent — safe to re-run. Leaves db + rubyapi-dev containers up.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

docker compose up -d db

if [ ! -f tmp/pids/.gitkeep ]; then mkdir -p tmp/pids; fi
if [ -f tmp/pids/server.pid ]; then
  docker run --rm -v "$PWD":/app rubyproject-api rm -f /app/tmp/pids/server.pid || true
fi

if docker ps --filter name=rubyapi-dev --filter status=running -q | grep -q .; then
  echo "rubyapi-dev already running on :3000"
else
  docker rm -f rubyapi-dev >/dev/null 2>&1 || true
  if ! docker image inspect rubyproject-api >/dev/null 2>&1; then
    docker compose build api
  fi
  docker compose run -d --name rubyapi-dev \
    -e RAILS_ENV=development \
    -e DATABASE_URL=postgresql://studioflow:password@db/studioflow_development \
    -e JWT_SECRET_KEY=dev_jwt_secret_key_for_local \
    -p 3000:3000 \
    api bash -c "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0 -p 3000" >/dev/null
fi

echo -n "waiting for :3000 "
for i in $(seq 1 60); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/api/v1/projects || true)
  if [ "$code" = "401" ] || [ "$code" = "200" ]; then echo "✓ ready"; exit 0; fi
  echo -n "."
  sleep 1
done
echo
echo "server did not become ready; last logs:"
docker logs --tail 50 rubyapi-dev
exit 1
