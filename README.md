# rubyProject — Creative Project Management API

Built to demonstrate production-level Rails API development

---

## Tech Stack

| Layer         | Technology                                |
| ------------- | ----------------------------------------- |
| Backend       | Ruby on Rails 7 (API mode)                |
| Database      | PostgreSQL (with JSONB & array columns)   |
| Auth          | Devise + JWT (hand-rolled)                |
| Serialization | jsonapi-serializer                        |
| Testing       | RSpec + FactoryBot + Shoulda-matchers     |
| Style linting | RuboCop                                   |
| Soft deletes  | discard gem                               |
| Rate limiting | rack-attack                               |
| Version ctrl  | Git / GitHub (feature branch workflow)    |
| Deployment    | AWS EC2 + RDS (target, not automated yet) |

---

## Architecture

Rails 7 API-only application. Frontend is a separate repository.

```
rubyProject/
├── app/
│   ├── controllers/
│   │   └── api/v1/            # Versioned REST controllers
│   ├── models/                # ActiveRecord models
│   ├── serializers/           # JSONAPI serializers
│   └── policies/              # Pundit authorization
├── db/
│   ├── migrate/               # Schema migrations
│   └── seeds.rb               # Development seed data
├── config/
│   └── initializers/
│       └── rack_attack.rb     # API rate limiting
├── spec/                      # RSpec test suite
│   ├── models/
│   ├── requests/
│   └── factories/
├── .github/
│   └── workflows/
│       └── ci.yml             # GitHub Actions CI
└── docker-compose.yml         # Local development environment
```

---

## Rails API Endpoints

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

### Milestones

| Method | Endpoint                          | Description      |
| ------ | --------------------------------- | ---------------- |
| GET    | `/api/v1/projects/:id/milestones` | List milestones  |
| POST   | `/api/v1/projects/:id/milestones` | Create milestone |
| PUT    | `/api/v1/milestones/:id`          | Update milestone |
| DELETE | `/api/v1/milestones/:id`          | Delete milestone |

### Dashboard

| Method | Endpoint                  | Description            |
| ------ | ------------------------- | ---------------------- |
| GET    | `/api/v1/dashboard/stats` | Aggregated KPI data    |
| GET    | `/api/v1/activity_feed`   | Cross-project activity |

---

## Key Features

- **Authenticated REST API** — JWT-based auth via Devise, role-based access via Pundit
- **Project lifecycle tracking** — Status transitions (backlog → active → review → completed)
- **Auto progress calculation** — Derived from milestone completion percentage, recalculated atomically within a database transaction
- **Soft deletes** — Projects are discarded (not hard-deleted), preserving audit trails and enabling recovery via `discard` gem
- **Paginated activity log** — Per-project audit history surfaced via API (25 entries/page), with eager-loaded user associations
- **Tag validation** — `tag_list` capped at 20 tags, each under 50 characters
- **Rate limiting** — 60 requests/min per IP on all API routes; 10 POSTs/min to prevent abuse via `rack-attack`
- **CI pipeline** — GitHub Actions runs RSpec + RuboCop on every push and PR

---

## Development Setup

```bash
# Clone
git clone git@github.com:EPW80/rubyProject.git && cd rubyProject

# Install dependencies
bundle install
cp .env.example .env          # set DATABASE_URL, JWT_SECRET_KEY

# Database
bin/rails db:create db:migrate db:seed

# Start server
bin/rails server               # http://localhost:3000

# Or via Docker (runs migrations + starts server)
docker compose up
```

---

## Testing

```bash
bundle exec rspec                    # Full suite
bundle exec rspec spec/models        # Models only
bundle exec rspec spec/requests      # API integration tests
bundle exec rubocop                  # Lint

# Or via Docker
docker compose run --rm api bundle exec rspec
```

---

## Git Workflow

```
main              ← production-ready
  ├─ feature/milestone-calendar
  └─ fix/progress-calculation-edge-case
```

PRs squash-merged into `main`.

---

## Relevant Skills Demonstrated

- **Ruby on Rails** — API mode, ActiveRecord, serializers (JSON:API), Pundit authorization, RSpec
- **PostgreSQL** — JSONB columns, array columns, GIN indexes, soft-delete patterns
- **Security** — JWT auth, Pundit policies, rack-attack rate limiting, fail-loud secret management
- **Testing** — RSpec request + model specs, FactoryBot, Shoulda-matchers, 31-test suite
- **CI/CD** — GitHub Actions pipeline (RSpec + RuboCop on push/PR)
- **Git** — Feature branches, conventional commits, PR-based workflow
