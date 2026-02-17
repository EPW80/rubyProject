# Studioflow — Creative Project Management OS
### Full Stack Portfolio Project · React + Ruby on Rails

Built to demonstrate production-level full-stack development

---

## Tech Stack

| Layer        | Technology                                |
|--------------|-------------------------------------------|
| Frontend     | React 18 (TypeScript), HTML5, CSS3        |
| Backend      | Ruby on Rails 7 (API mode)                |
| Database     | PostgreSQL (with JSONB & array columns)   |
| Auth         | Devise + JWT (devise-jwt gem)             |
| Serialization| jsonapi-serializer                        |
| Testing      | RSpec + FactoryBot + Shoulda-matchers     |
| Style linting| RuboCop (standard Rails config)           |
| JS tooling   | Vite + ESLint + Prettier                  |
| Soft deletes | discard gem                               |
| Rate limiting| rack-attack                               |
| Version ctrl | Git / GitHub (feature branch workflow)    |
| Deployment   | AWS EC2 + RDS + S3 + CloudFront           |

---

## Architecture

```
studioflow/
├── frontend/                  # React 18 + TypeScript (Vite)
│   ├── src/
│   │   ├── components/        # Reusable UI components
│   │   ├── pages/             # Route-level page components
│   │   ├── hooks/             # Custom React hooks
│   │   ├── api/               # Axios API client layer
│   │   ├── store/             # Zustand global state
│   │   └── types/             # TypeScript type definitions
│   └── ...
│
└── rails-api/                 # Rails 7 API-only app
    ├── app/
    │   ├── controllers/
    │   │   └── api/v1/        # Versioned REST controllers
    │   ├── models/            # ActiveRecord models
    │   ├── serializers/       # JSONAPI serializers
    │   ├── policies/          # Pundit authorization
    │   └── services/          # Service objects (business logic)
    ├── db/
    │   ├── migrate/           # Schema migrations
    │   └── seeds.rb           # Development seed data
    ├── config/
    │   └── initializers/
    │       └── rack_attack.rb # API rate limiting
    └── spec/                  # RSpec test suite
        ├── models/
        ├── requests/
        └── factories/
```

---

## Rails API Endpoints

### Projects
| Method | Endpoint                            | Description                              |
|--------|-------------------------------------|------------------------------------------|
| GET    | `/api/v1/projects`                  | List projects (paginated, filterable)    |
| POST   | `/api/v1/projects`                  | Create project                           |
| GET    | `/api/v1/projects/:id`              | Get project details                      |
| PUT    | `/api/v1/projects/:id`              | Update project                           |
| DELETE | `/api/v1/projects/:id`              | Soft-delete project (recoverable)        |
| PATCH  | `/api/v1/projects/:id/update_status`| Change status (transactional)            |
| GET    | `/api/v1/projects/:id/activity`     | Paginated activity log (25/page)         |

### Milestones
| Method | Endpoint                              | Description         |
|--------|---------------------------------------|---------------------|
| GET    | `/api/v1/projects/:id/milestones`     | List milestones     |
| POST   | `/api/v1/projects/:id/milestones`     | Create milestone    |
| PUT    | `/api/v1/milestones/:id`              | Update milestone    |
| DELETE | `/api/v1/milestones/:id`              | Delete milestone    |

### Dashboard
| Method | Endpoint                       | Description              |
|--------|--------------------------------|--------------------------|
| GET    | `/api/v1/dashboard/stats`      | Aggregated KPI data      |
| GET    | `/api/v1/activity_feed`        | Cross-project activity   |

---

## Key Features

- **Authenticated REST API** — JWT-based auth via Devise, role-based access via Pundit
- **Project lifecycle tracking** — Status transitions (backlog → active → review → completed)
- **Auto progress calculation** — Derived from milestone completion percentage, recalculated atomically within a database transaction
- **Soft deletes** — Projects are discarded (not hard-deleted), preserving audit trails and enabling recovery via `discard` gem
- **Paginated activity log** — Per-project audit history surfaced via API (25 entries/page), with eager-loaded user associations
- **Tag validation** — `tag_list` capped at 20 tags, each under 50 characters
- **Rate limiting** — 60 requests/min per IP on all API routes; 10 POSTs/min to prevent abuse via `rack-attack`
- **Kanban board** — Drag-and-drop task management (React + DnD Kit)
- **Responsive UI** — Mobile-first layout with CSS Grid + Flexbox
- **Accessible markup** — ARIA labels, keyboard navigable, meets WCAG 2.1 AA

---

## Development Setup

```bash
# Clone
git clone git@github.com:your-handle/studioflow.git && cd studioflow

# Backend
cd rails-api
bundle install
cp .env.example .env          # set DATABASE_URL, JWT_SECRET_KEY
rails db:create db:migrate db:seed
# Migration required for soft deletes:
# rails g migration AddDiscardedAtToProjects discarded_at:datetime:index
rails server -p 3001

# Frontend
cd ../frontend
npm install
npm run dev                   # Vite dev server on :5173
```

---

## Testing

```bash
# Rails (RSpec)
cd rails-api
bundle exec rspec              # Full suite
bundle exec rspec spec/models  # Models only
bundle exec rspec spec/requests# API integration tests

# JavaScript (Vitest)
cd frontend
npm run test
npm run test:coverage
```

---

## Git Workflow

```
main              ← production-ready
  └─ develop      ← integration branch
       ├─ feature/project-kanban
       ├─ feature/milestone-calendar
       └─ fix/progress-calculation-edge-case
```

PRs squash-merged into `develop`, then released to `main` on sprint completion.

---

## Relevant Skills Demonstrated

- **ReactJS** — Hooks, Context, custom hooks, component composition
- **Ruby on Rails** — MVC, ActiveRecord, API mode, serializers, Pundit, RSpec
- **HTML5 / CSS3** — Semantic markup, Grid, Flexbox, animations
- **Node.js** — Vite build pipeline, npm ecosystem
- **JavaScript** — ES2024, async/await, drag & drop, real-time UI updates
- **Git** — Feature branches, conventional commits, PR-based workflow
- **Collaboration** — Client-facing wireframe reviews, sprint planning, agile ceremonies
