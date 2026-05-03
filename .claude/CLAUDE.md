# studioFlow Rails API

A Rails 7.2 API-only application for creative project management. PostgreSQL backend with JSON:API serialization.

## Stack & Conventions

- **Auth**: Devise for user model; JWT (hand-rolled in ApplicationController) for stateless API tokens. Each request must include `Authorization: Bearer <token>`.
- **Authorization**: Pundit policies in `app/policies/` — one policy per model, checked with `authorize(record)` in controllers.
- **Serialization**: jsonapi-serializer — responses wrap data/relationships. `ProjectSerializer` includes owner, members, milestones, comments.
- **Soft deletes**: Discard gem — `discarded_at` column, `default_scope -> { kept }` hides deleted records, `with_discarded` scope recovers them.
- **Pagination**: will_paginate gem — params `?page=2&per_page=10`, response includes meta.
- **Rate limiting**: rack-attack — 60 requests/min, 10 POST/min per IP.

## Where Things Go

- **API routes**: `app/controllers/api/v1/` (HTTP layer, parameter parsing, status codes).
- **Business logic**: `app/models/` (validations, associations, scopes, calculations like `recalculate_progress!`).
- **Access control**: `app/policies/project_policy.rb` — answers "can user do X to record Y?".
- **Responses**: `app/serializers/` — shapes JSON, includes relationships.
- **Tests**: RSpec request specs in `spec/requests/api/v1/` (happy path, validation errors, auth), model specs in `spec/models/` (validations, associations, scopes).

## Databases & Migrations

PostgreSQL locally (docker-compose) or RDS in production. Migrations in `db/migrate/`. Run `bin/rails db:prepare` to set up locally.

## Commands

- `bundle exec rspec` — run full test suite
- `bundle exec rubocop` — lint + style check (auto-fix: `rubocop -A`)
- `docker compose build && docker compose run --rm api bundle exec rspec` — test in Docker
- `bin/rails db:seed` — load seed data

## Self-Improvement Loop

After feedback on code, ask: "Should I update CLAUDE.md so I don't make that mistake again?" I'll refine these rules to match your preferences.
