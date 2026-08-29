# AGENTS.md — AI Agent Context for Multi-tenant SvelteKit Starter

> This file tells AI coding agents everything they need to work effectively in this codebase.

## Project Overview

A production-shaped B2B SaaS foundation for SvelteKit with multi-tenancy wired end-to-end. Implements organizations, invitations, role-based access control, seat-based billing, and an append-only audit log.

**Status:** v0.2 — 52 tests passing, CI-verified, production-ready foundation.

## Quick Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm test             # Run vitest suite (52 tests, :memory: SQLite)
npm run check        # Run svelte-check (TypeScript validation)
npm run build        # Production build
npm run db:generate  # Generate SQL migrations after schema.ts changes
```

## Architecture

```
routes (+page.server.ts)      → thin: parse form → call service → fail/redirect
        ↓
services (orgs/members/invites)  → domain logic, pure functions, Db passed in
        ↓
rbac.ts / billing/            → policy + payment seams
        ↓
db/index.ts                   → better-sqlite3 + drizzle + migrations
```

### Critical Rules

1. **Routes NEVER touch the database directly** — all writes go through services
2. **Services are framework-free** — import nothing from `@sveltejs/kit`
3. **Every mutating service call re-derives authority** — callers pass `actorRole`, fetched fresh inside the same request
4. **Errors carry machine codes** — `AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`
5. **One error mapper** — `lib/server/http.ts:errorToFail()` turns errors into HTTP responses

## Key Files

| File | Purpose |
|------|---------|
| `src/lib/server/db/schema.ts` | Drizzle schema — users, sessions, organizations, memberships, invites, audit_log |
| `src/lib/server/rbac.ts` | Roles, permission matrix (`MATRIX`), hierarchy helpers (`mayActOn`, `mayGrant`) |
| `src/lib/server/auth.ts` | scrypt hashing, session issue/verify/revoke |
| `src/lib/server/ratelimit.ts` | `RateLimiter` interface + sliding-window implementation |
| `src/lib/server/http.ts` | `errorToFail()` — maps domain errors to HTTP responses |
| `src/lib/server/services/` | Domain logic: orgs, members, invites (pure functions taking `Db`) |
| `src/lib/server/billing/` | `BillingAdapter` interface, mock implementation, wiring point |
| `drizzle/` | Checked-in SQL migrations (applied via `migrate()` at boot) |
| `tests/` | Vitest suites against `:memory:` databases |

## RBAC Model

**Roles:** `owner` (rank 2) > `admin` (rank 1) > `member` (rank 0)

**Hierarchy rules (enforced everywhere):**
1. Act downward only — `rank(actor) > rank(target)`
2. Grant strictly below yourself — `rank(actor) > rank(granted)`
3. No self-modification
4. Single-owner invariant — last owner cannot leave or be removed

**Capability matrix** (in `rbac.ts` `MATRIX`):
- `owner`: all permissions
- `admin`: org.view, members.view, members.invite, members.remove*, members.role.set*, invites.revoke, audit.view
- `member`: org.view, members.view

*subject to hierarchy rules

## Database

- **Driver:** better-sqlite3 (synchronous, serialized per process)
- **ORM:** Drizzle
- **Location:** `./data/app.db` (override with `DATA_DIR`)
- **Migrations:** Auto-applied at startup via `migrate()`
- **Schema portability:** Replace `db/index.ts` driver to swap to Postgres

### Key Schema Tables
- `users` — email + scrypt password hash
- `sessions` — sha256(token) as PK, user_id, expiry
- `organizations` — name, slug, created_at_ms
- `memberships` — org_id, user_id, role (unique on org_id + user_id)
- `invites` — org_id, token_hash, role, expiry, accepted/revoked timestamps
- `audit_log` — org_id, actor_user_id, action, metadata (append-only, no UPDATE/DELETE)

## Testing

- **Framework:** Vitest
- **Database:** `:memory:` SQLite (fast, isolated)
- **Run:** `npm test`
- **Current count:** 52 tests across 7 suites

### Test Files
| File | Coverage |
|------|----------|
| `tests/auth.test.ts` | Password hashing, session lifecycle |
| `tests/rbac.test.ts` | Matrix pinning, hierarchy rules |
| `tests/orgs-members.test.ts` | Org CRUD, membership management |
| `tests/invites-seats.test.ts` | Invite lifecycle, seat limits |
| `tests/ratelimit.test.ts` | Sliding-window semantics, eviction |
| `tests/http.test.ts` | HTTP-level flows, redirect safety |
| `tests/smoke.test.ts` | Build verification |

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DATA_DIR` | `./data` | SQLite file location |
| `MOCK_PLAN_SEATS` | `3` | Seat limit for MockBilling |
| `AUTH_FAILED_ATTEMPTS` | `5` | Failed attempts per window |
| `AUTH_WINDOW_MS` | `900000` | Sliding window (15 min) |

## Code Style

- TypeScript strict mode
- Server-side enforcement everywhere
- Errors use typed error classes (not strings)
- Timestamps in milliseconds, UTC only
- No ORM lock-in at service boundaries

## Common Patterns

### Adding a new service action
1. Add the permission to `MATRIX` in `rbac.ts` if needed
2. Create the service function in `src/lib/server/services/`
3. Accept `Db` as first argument, `actorRole` as needed
4. Call `requirePermission()` before any write
5. Write audit log entry in the same service call
6. Add tests in `tests/`

### Adding a new route
1. Create `+page.server.ts` in the route directory
2. Parse form data / URL params
3. Call service functions (never touch DB directly)
4. Handle errors via `errorToFail()`
5. Return redirects or data

### Modifying the schema
1. Edit `src/lib/server/db/schema.ts`
2. Run `npm run db:generate` to create migration SQL
3. Review the generated SQL in `drizzle/`
4. Migrations apply automatically at startup

## Build & CI

- **CI:** GitHub Actions (install → test → check → build)
- **Build:** `npm run build` (adapter-auto)
- **No external services required** for development or testing
