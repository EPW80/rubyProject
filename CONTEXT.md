# Domain Language — Studioflow

Vocabulary for discussing this codebase without re-deriving concepts.

## Entities

**Project**
The central domain object. Owned by a User. Has a status (backlog/active/review/on_hold/completed/archived), progress (0–100%, derived from milestones), deadline, color, tags, client name. Soft-deletable.

**Milestone**
Completion checkpoint within a Project. Has a `completed` flag (boolean). Progress = (completed milestones / total milestones) × 100.

**ProjectMembership**
Join table (users ↔ projects) carrying a role: owner (full control), member (edit/view), viewer (view-only). Soft-deletable.

**Comment**
Discussion thread entry: belongs to Project and User, has a body (text).

**ActivityLog**
Append-only audit trail. Captures action (e.g., "status_updated"), user who triggered it, metadata (JSONB) with details (old_status, new_status, etc.). Never deleted.

**User**
Devise model. Has email (unique), encrypted password. Owns Projects. Can be a member of Projects via ProjectMembership.

## Concepts

**Discarded / Soft-delete**
A record with `discarded_at` set is logically deleted but not removed from DB. Hidden by `default_scope -> { kept }`. Recoverable via `.with_discarded` scope or `.undiscard` method.

**Seam / Interface**
Controllers are seams: HTTP layer transforms requests → domain operations → serialized responses. Models define behavior; policies define access.

**Access control**
Pundit policies: ApplicationPolicy (base, deny-by-default) and ProjectPolicy (owner/member rules). Authorization checked with `authorize(record)` in controllers.

**Recalculate**
Progress is materialized (stored in `projects.progress` column). The method `#recalculate_progress!` reads milestones and updates the column. Called explicitly when milestones change.

## Avoid

- "Ticket" — use "issue" if borrowed; unused in this repo.
- "Backlog manager" — this isn't a backlog tool; Studioflow is project-centric.
- "Frontend" — this repo is API-only; frontend is separate.
