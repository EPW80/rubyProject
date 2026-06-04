# studioFlow — Creative Project Management API

Built to demonstrate production-level Rails API development

---

## Tech Stack

| Layer         | Technology                                |
| ------------- | ----------------------------------------- |
| Backend       | Ruby on Rails 8.1 (API mode)              |
| Database      | PostgreSQL (with JSONB & array columns)   |
| Auth          | Devise + devise-jwt (stateless JWT)       |
| Serialization | jsonapi-serializer                        |
| Pagination    | pagy                                      |
| Testing       | RSpec + FactoryBot + Shoulda + SimpleCov  |
| Style linting | RuboCop (+ performance/rspec plugins)     |
| Security      | Brakeman + bundler-audit + Dependabot     |
| Soft deletes  | discard gem                               |
| Rate limiting | rack-attack                               |
| Version ctrl  | Git / GitHub (feature branch workflow)    |
| Deployment    | Docker (multi-stage) + Thruster + Kamal   |

---

## Architecture

Rails 8.1 API-only application. Frontend is a separate repository.

```text
studioFlow/
├── app/
│   ├── controllers/
│   │   └── api/v1/            # Versioned REST controllers
│   │       └── auth/          # devise-jwt session/registration controllers
│   ├── models/                # ActiveRecord models (incl. JwtDenylist)
│   ├── serializers/           # JSONAPI serializers
│   └── policies/              # Pundit authorization
├── db/
│   ├── migrate/               # Schema migrations
│   └── seeds.rb               # Development seed data
├── config/
│   ├── deploy.yml             # Kamal deployment config
│   └── initializers/
│       ├── cors.rb            # ALLOWED_ORIGINS allowlist
│       ├── devise.rb          # devise-jwt dispatch/revocation
│       ├── pagy.rb            # Pagination defaults
│       └── rack_attack.rb     # API rate limiting
├── spec/                      # RSpec test suite (SimpleCov-gated)
│   ├── models/
│   ├── requests/
│   └── factories/
├── .github/
│   ├── dependabot.yml         # Automated dependency PRs
│   └── workflows/
│       └── ci.yml             # GitHub Actions: test, lint, security
├── Dockerfile                 # Production multi-stage image (Thruster, Kamal)
├── Dockerfile.dev             # Dev/test image used by docker-compose
└── docker-compose.yml         # Local development environment
```

---

## Rails API Endpoints

### Auth

| Method | Endpoint          | Description                                              |
| ------ | ----------------- | ------------------------------------------------------- |
| POST   | `/api/v1/signup`  | Register; returns a JWT in the `Authorization` header   |
| POST   | `/api/v1/login`   | Authenticate; returns a JWT in the `Authorization` header |
| DELETE | `/api/v1/logout`  | Revoke the current JWT (denylist)                       |

All other endpoints require `Authorization: Bearer <token>`.

### Projects

| Method | Endpoint                             | Description                           |
| ------ | ------------------------------------ | ------------------------------------- |
| GET    | `/api/v1/projects`                   | List projects (paginated, filterable) |
| POST   | `/api/v1/projects`                   | Create project                        |
| GET    | `/api/v1/projects/:id`               | Get project details                   |
| PUT    | `/api/v1/projects/:id`               | Update project                        |
| DELETE | `/api/v1/projects/:id`               | Soft-delete project (recoverable)     |
| PATCH  | `/api/v1/projects/:id/update_status` | Change status (transactional)         |
| GET    | `/api/v1/projects/:id/activity`      | Paginated activity log (25/page)      |

### Milestones & Dashboard (Planned)

Milestone CRUD (`/api/v1/projects/:id/milestones`) and dashboard endpoints
(`/api/v1/dashboard/stats`, `/api/v1/activity_feed`) are on the roadmap and not
yet routed. The `Milestone` model and per-project `activity` endpoint exist today.

---

## Key Features

- **Authenticated REST API** — stateless JWT auth via Devise + devise-jwt (login/signup/logout with token revocation via a denylist), role-based access via Pundit
- **Project lifecycle tracking** — Status transitions (backlog → active → review → completed)
- **Auto progress calculation** — Derived from milestone completion percentage, recalculated atomically within a database transaction
- **Soft deletes** — Projects are discarded (not hard-deleted), preserving audit trails and enabling recovery via `discard` gem
- **Paginated activity log** — Per-project audit history surfaced via API (25 entries/page), with eager-loaded user associations
- **Tag validation** — `tag_list` capped at 20 tags, each under 50 characters
- **Rate limiting** — 60 requests/min per IP on all API routes; 10 POSTs/min to prevent abuse via `rack-attack`
- **CORS allowlist** — origins restricted via the `ALLOWED_ORIGINS` env var (no wildcard); secure default of no cross-origin when unset
- **Security scanning** — Brakeman (static analysis) and bundler-audit (dependency advisories) run in CI; Dependabot opens update PRs
- **CI pipeline** — GitHub Actions runs RSpec (SimpleCov-gated), RuboCop, and security scans on every push and PR

---

## Development Setup

### Docker (recommended — no local Ruby needed)

```bash
git clone https://github.com/EPW80/studioFlow.git && cd studioFlow

.claude/skills/run-studioflow/start.sh   # idempotent: brings up db + api on :3000
.claude/skills/run-studioflow/smoke.sh   # end-to-end check: signup → JWT → CRUD → logout
.claude/skills/run-studioflow/stop.sh    # tear down (postgres volume preserved)
```

`start.sh` builds the dev image on first run (~25s), runs `db:prepare`, and launches
Rails in development mode against a postgres container. See
[`.claude/skills/run-studioflow/SKILL.md`](.claude/skills/run-studioflow/SKILL.md) for
endpoints, gotchas (stale pidfile, the `status` enum, JWT in response headers), and
the `docker compose run` invocations for tests.

### Bare metal (requires Ruby 3.3.10 + PostgreSQL locally)

```bash
cp .env.example .env          # set DATABASE_URL, JWT_SECRET_KEY, ALLOWED_ORIGINS
bin/setup --skip-server       # bundle install + db:prepare
bin/rails server              # http://localhost:3000
```

---

## Testing

```bash
bundle exec rspec                    # Full suite (SimpleCov: 90% line / 65% branch gate)
bundle exec rspec spec/models        # Models only
bundle exec rspec spec/requests      # API integration tests
bundle exec rubocop                  # Lint
bundle exec brakeman                 # Static security analysis
bundle exec bundle-audit check --update  # Dependency advisories

# Or via Docker
docker compose run --rm api bundle exec rspec
```

---

## Git Workflow

```text
main              ← production-ready
  ├─ feature/milestone-calendar
  └─ fix/progress-calculation-edge-case
```

PRs squash-merged into `main`.

---

## Relevant Skills Demonstrated

- **Ruby on Rails 8** — API mode, ActiveRecord, serializers (JSON:API), Pundit authorization, pagy pagination, RSpec
- **PostgreSQL** — JSONB columns, array columns, GIN indexes, soft-delete patterns
- **Security** — devise-jwt auth with token revocation, Pundit policies, CORS allowlist, rack-attack rate limiting, Brakeman + bundler-audit scanning, fail-loud secret management
- **Testing** — RSpec request + model specs, FactoryBot, Shoulda-matchers, SimpleCov coverage gate (43-example suite)
- **CI/CD** — GitHub Actions pipeline (RSpec + RuboCop + security scans on push/PR), Dependabot
- **Deployment** — Multi-stage Docker image (Thruster), Kamal config
- **Git** — Feature branches, conventional commits, PR-based workflow
