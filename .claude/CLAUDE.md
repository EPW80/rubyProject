# studioFlow Rails API

A Rails 8.1 API-only application for creative project management. PostgreSQL backend with JSON:API serialization.

## Stack & Conventions

- **Auth**: Devise + devise-jwt for stateless API tokens. Each request must include `Authorization: Bearer <token>`. Endpoints: `POST /api/v1/signup`, `POST /api/v1/login` (token returned in the `Authorization` response header), `DELETE /api/v1/logout` (revokes the token). Revoked tokens are tracked in the `jwt_denylist` table (`JwtDenylist` model). `JWT_SECRET_KEY` env var signs tokens.
- **Authorization**: Pundit policies in `app/policies/` — one policy per model, checked with `authorize(record)` in controllers.
- **Serialization**: jsonapi-serializer — responses wrap data/relationships. `ProjectSerializer` includes owner, members, milestones, comments.
- **Soft deletes**: Discard gem — `discarded_at` column, `default_scope -> { kept }` hides deleted records, `with_discarded` scope recovers them.
- **Pagination**: pagy gem (`Pagy::Backend` in ApplicationController) — params `?page=2&per_page=10`, response includes `meta: { total, page, per_page, pages }`.
- **CORS**: `config/initializers/cors.rb`, driven by the `ALLOWED_ORIGINS` env var (comma-separated). Empty = no cross-origin (secure default).
- **Rate limiting**: rack-attack — 60 requests/min, 10 POST/min per IP.
- **Deploy**: production multi-stage `Dockerfile` (Thruster + non-root) for Kamal (`config/deploy.yml`). `Dockerfile.dev` is used by docker-compose for the test suite.

## Where Things Go

- **API routes**: `app/controllers/api/v1/` (HTTP layer, parameter parsing, status codes).
- **Business logic**: `app/models/` (validations, associations, scopes, calculations like `recalculate_progress!`).
- **Access control**: `app/policies/project_policy.rb` — answers "can user do X to record Y?".
- **Responses**: `app/serializers/` — shapes JSON, includes relationships.
- **Tests**: RSpec request specs in `spec/requests/api/v1/` (happy path, validation errors, auth), model specs in `spec/models/` (validations, associations, scopes).

## Databases & Migrations

PostgreSQL locally (docker-compose) or RDS in production. Migrations in `db/migrate/`. Run `bin/rails db:prepare` to set up locally.

## Commands

- `bundle exec rspec` — run full test suite (SimpleCov gate: 90% line / 65% branch)
- `bundle exec rubocop` — lint + style check (auto-fix: `rubocop -A`)
- `bundle exec brakeman` / `bundle exec bundle-audit check --update` — security scans
- `docker compose build && docker compose run --rm api bundle exec rspec` — test in Docker
- `bin/rails db:seed` — load seed data

## Self-Improvement Loop

After feedback on code, ask: "Should I update CLAUDE.md so I don't make that mistake again?" I'll refine these rules to match your preferences.
