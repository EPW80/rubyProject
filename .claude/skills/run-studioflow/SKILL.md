---
name: run-studioflow
description: Build, run, and drive the studioFlow Rails API. Use when asked to start studioflow, launch the Rails server, smoke-test the API, hit /api/v1/projects, exercise the auth/JWT flow, or interact with the running app.
---

A Rails 8.1 API-only app (JWT auth, Pundit, PostgreSQL). Local Ruby is not installed — everything runs in Docker. Drive the running server with `curl`; the canonical end-to-end check is `.claude/skills/run-studioflow/smoke.sh`, which exercises signup → JWT → CRUD → policy → activity log → logout/revocation.

All paths below are relative to the repo root.

## Prerequisites

Docker + docker compose. Nothing else — Ruby/bundler/postgres all come from images.

```bash
docker --version && docker compose version
```

## Setup

None. `start.sh` builds the `rubyproject-api` image on first run (~25s) and reuses it after. The dev db is the same `postgres:16-alpine` container `docker-compose.yml` defines for tests; only the database name differs (`studioflow_development` vs `studioflow_test`).

## Run (agent path)

```bash
.claude/skills/run-studioflow/start.sh   # idempotent; brings up db + api on :3000
.claude/skills/run-studioflow/smoke.sh   # signup→create→update_status→activity→logout, asserts each step
.claude/skills/run-studioflow/stop.sh    # remove api container, stop db (data preserved)
```

What `start.sh` does:
- `docker compose up -d db` (postgres on the compose-internal network)
- removes any stale `tmp/pids/server.pid` via a throwaway container (host can't `rm` it; see Gotchas)
- launches a detached `rubyapi-dev` container running `rails db:prepare && rails server -b 0.0.0.0 -p 3000` with `RAILS_ENV=development`
- polls `GET /api/v1/projects` until it returns 401 or 200 (up to 60s)

What `smoke.sh` asserts:
| step | endpoint | expected |
|---|---|---|
| signup | `POST /api/v1/signup` | 201 + JWT in `Authorization` response header |
| unauth list | `GET /api/v1/projects` | 401 |
| auth list | `GET /api/v1/projects` | 200 + `meta.total = 0` (Pundit scope per user) |
| create | `POST /api/v1/projects` | 201, body has `data.id` |
| update_status | `PATCH /api/v1/projects/:id/update_status` | 200 + `status` updated |
| activity | `GET /api/v1/projects/:id/activity` | 200 + log entries `created` and `status_changed` |
| logout | `DELETE /api/v1/logout` | 200 |
| revoked | `GET /api/v1/projects` with revoked JWT | 401 `"revoked token"` (JwtDenylist) |

Each run uses `smoke+$(date +%s)@example.com` to keep the dev DB additive across runs.

Server logs: `docker logs rubyapi-dev`. Rails console: `docker exec -it rubyapi-dev bundle exec rails c`.

## Run (human path)

There isn't a separate one — `start.sh` produces an HTTP server you hit with `curl`, `Postman`, or a frontend. The only "human" difference is you'd watch logs live:

```bash
docker logs -f rubyapi-dev
```

## Test

The `docker-compose.yml` `api` service is **wired for the test suite**, not the dev server — its command is hardcoded to `rspec`. To run tests:

```bash
docker compose run --rm api    # runs db:create db:migrate then `rspec --format documentation`
```

SimpleCov gate: 90% line / 65% branch. Do not run this while `rubyapi-dev` is up — they share the bundle_cache volume; concurrent bundler installs can corrupt it. Stop the dev container first:

```bash
docker rm -f rubyapi-dev && docker compose run --rm api
```

## Gotchas

- **`docker-compose.yml` is hardcoded to RSpec.** Plain `docker compose up api` runs the test suite, not the server. `start.sh` works around this by overriding `command`, `RAILS_ENV`, `DATABASE_URL`, and adding `-p 3000:3000`.
- **Stale `tmp/pids/server.pid` blocks restarts.** The container runs as root, so the pidfile it writes is root-owned on the bind-mounted host directory — the host user can't `rm` it. `start.sh` deletes it via a throwaway root container before relaunch. Symptom if you skip this: `A server is already running (pid: 1, file: /app/tmp/pids/server.pid). Exiting`.
- **`status: "draft"` is not valid.** The `Project` `enum :status` accepts `backlog | active | review | on_hold | completed | archived` only. Sending any other value raises `ArgumentError` and returns 500 (not 422) from `POST /api/v1/projects` — only `update_status` rescues `ArgumentError` into 422.
- **`Project` requires `name` and `client`.** Both have presence validations (and `name` has min length 2). The README/CLAUDE.md don't mention this; CRUD via `curl` fails with 422 without them.
- **Pundit scopes the index per user.** A freshly signed-up user sees `meta.total = 0` even if other users own dozens of projects. Don't infer "DB is empty" from an empty list.
- **JWT is returned in the response header, not the body.** Capture `Authorization:` from response headers on `/signup` and `/login`. The body has the user record only. Send the captured value back as-is (`Authorization: Bearer …`) — include the `Bearer ` prefix.
- **`--service-ports` and `-p` are mutually exclusive in `docker compose run`.** `start.sh` uses `-p 3000:3000` (compatible with named-container mode).

## Troubleshooting

- **`A server is already running (pid: 1, file: /app/tmp/pids/server.pid)`** — stale pidfile from a previous container. `start.sh` clears this; if you launched manually, run `docker run --rm -v "$PWD":/app rubyproject-api rm -f /app/tmp/pids/server.pid`.
- **`HTTP 500 ArgumentError: 'X' is not a valid status`** on `POST /api/v1/projects` — use one of the enum values listed in Gotchas.
- **`HTTP 422 "Name can't be blank", "Client can't be blank"`** — these fields are required even though they're not in the README's example payloads.
- **`HTTP 403 "Forbidden"` on `update_status` for a project you just created** — almost always a smoke-script bug parsing the wrong `id` out of the JSON:API response (the *last* `"id":"N"` is the owner's user id, not the project id). Grab the *first* `"id":"N"`.
- **`waiting for :3000 ` hangs past 60s** — `docker logs rubyapi-dev`. Common causes: db not healthy yet (rerun `start.sh`), `bundle install` running on a fresh image (give it ~25s), `RAILS_MASTER_KEY` issues if you've changed credentials (not needed for dev).
- **`docker compose run` errors `--service-ports and --publish are incompatible`** — drop `--service-ports`, use `-p 3000:3000` only.
