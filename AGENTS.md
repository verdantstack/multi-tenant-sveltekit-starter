# AGENTS.md — AI Agent Context for Multi-tenant SvelteKit Starter

> This file tells AI coding agents everything they need to work effectively in this codebase.

## Project Overview

A production-shaped B2B SaaS foundation for SvelteKit with multi-tenancy wired end-to-end. Implements organizations, invitations, role-based access control, seat-based billing, and an append-only audit log.

**Status:** v0.2.15 — 475 tests passing, clean-room-install verified, production-ready foundation. Coverage is 100% statements / branches / functions / lines; the ≥ 95% floor in `vitest.config.ts` remains the enforced minimum.

## Quick Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm test             # Run vitest suite (475 tests, :memory: SQLite)
npm run test:coverage  # Run with coverage enforcement — MUST pass before any commit/release
npm run check        # Run svelte-check (TypeScript validation)
npm run build        # Production build
npm run db:generate  # Generate SQL migrations after schema.ts changes
npm run db:migrate   # Apply migrations once, before a multi-instance deploy (see docs/deployment.md)
```

## Architecture

```
routes (+page.server.ts)      → thin: parse form → call service → fail/redirect
        ↓
services (orgs/members/invites/sessions) → domain logic, pure functions, Db in
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
5. **One error mapper** — `lib/server/http.ts:errorToFail()` turns errors into HTTP responses. It maps only **registered** codes; anything else is a logged, generic 500, so a driver error can never reach a browser as a 400 carrying schema detail
6. **Self-service surfaces re-derive the caller from the session token** — `services/sessions.ts` takes `{ sessionToken }`, never a `userId`, and derives the user id internally. **Use this shape for any new self-service surface.** A user id arriving as an argument is safe only because the caller re-derived it correctly; the call site is then load-bearing, and a future route that reads it off a form silently escalates. Taking the token moves the check inside the service where it cannot be forgotten, and scopes the write to a value the browser cannot forge. Where a port can only thread a user id, the delete must be SQL-scoped to it — belt and braces, never the belt alone
7. **Every auth surface is rate limited** — `/login`, `/signup` and both invite-accept actions consult `authLimiter` before any scrypt work. A new login form that forgets this re-opens a credential oracle

### Password hashing

`auth.ts` uses scrypt at `N = 2^17, r = 8, p = 1` — the minimum CPU/memory cost
with block size 8 and parallelism 1 that OWASP's Password Storage Cheat Sheet
names for scrypt when Argon2id is unavailable
(<https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html>).

Two consequences a change must respect:

- **`maxmem` moves with `N`.** scrypt needs `128 * N * r` bytes — 128 MiB at the
  shipped value — and Node defaults `maxmem` to 32 MiB, throwing
  `ERR_CRYPTO_INVALID_SCRYPT_PARAMS` rather than allocating. `SCRYPT` and
  `SCRYPT_MAXMEM` are declared together for exactly that reason.
- **Existing hashes keep working.** `format()` encodes `scheme$N$r$p$salt$hash`
  and `verifyPassword()` reads the parameters back out, so raising the work factor
  never invalidates a stored row; it is upgraded only when its owner next sets a
  password. `tests/scrypt-upgrade.test.ts` pins that path.

## Key Files

| File                          | Purpose                                                                          |
| ----------------------------- | -------------------------------------------------------------------------------- |
| `src/lib/server/db/schema.ts` | Drizzle schema — users, sessions, organizations, memberships, invites, audit_log |
| `src/lib/server/rbac.ts`      | Roles, permission matrix (`MATRIX`), hierarchy helpers (`mayActOn`, `mayGrant`)  |
| `src/lib/server/auth.ts`      | scrypt hashing, session issue/verify/revoke/list/cleanup                         |
| `src/lib/server/ratelimit.ts` | `RateLimiter` interface + sliding-window implementation                          |
| `src/lib/server/http.ts`      | `errorToFail()` — maps domain errors to HTTP responses                           |
| `src/lib/server/services/`    | Domain logic: orgs, members, invites, sessions (pure functions taking `Db`)      |
| `src/lib/server/billing/`     | `BillingAdapter` interface, mock implementation, wiring point                    |
| `drizzle/`                    | Checked-in SQL migrations (applied via `migrate()` at boot)                      |
| `scripts/migrate.ts`          | Standalone runner — the controlled writer in multi-instance deploys              |
| `tests/`                      | Vitest suites against `:memory:` databases                                       |
| `Dockerfile`                  | Multi-stage Docker build (Node 24 Alpine)                                        |
| `docker-compose.yml`          | Docker Compose with persistent SQLite volume                                     |
| `docs/deployment.md`          | Deployment guide (Docker, VPS, Cloudflare, Vercel, Fly, Postgres swap)           |
| `docs/ai-billing.md`          | Usage-based billing adapter pattern (AI tokens, metered pricing)                 |

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

- `users` — email + scrypt password hash (N=2^17, r=8, p=1; the parameters are stored inline)
- `sessions` — sha256(token) as PK, user_id, expiry
- `organizations` — name, slug, created_at_ms
- `memberships` — org_id, user_id, role (unique on org_id + user_id)
- `invites` — org_id, token_hash, role, expiry, accepted/revoked timestamps
- `audit_log` — org_id, actor_user_id, action, metadata (append-only, no UPDATE/DELETE)

## Testing

- **Framework:** Vitest
- **Database:** `:memory:` SQLite (fast, isolated)
- **Run:** `npm test`
- **Current count:** 475 tests across 24 suites
- **Coverage threshold:** ≥ 95% statements/branches/functions/lines (enforced in `vitest.config.ts`). Measured at the time of writing: **100% on all four**
- **Coverage command:** `npm run test:coverage` (fails if < 95%; run before every commit)
- **Excluded from coverage:** `db/schema.ts`, `db/index.ts`, `billing/index.ts`, `ratelimit.ts` (infrastructure, not business logic)

### Test Files

| File                                | Coverage                                                               |
| ----------------------------------- | ---------------------------------------------------------------------- |
| `tests/auth.test.ts`                | Password hashing, session lifecycle, expiry                            |
| `tests/rbac.test.ts`                | Matrix pinning, hierarchy rules                                        |
| `tests/orgs-members.test.ts`        | Org CRUD, membership management, slug rules                            |
| `tests/invites-seats.test.ts`       | Invite lifecycle, seat limits, TTL, email normalization                |
| `tests/ratelimit.test.ts`           | Sliding-window semantics, eviction                                     |
| `tests/http.test.ts`                | HTTP-level flows, redirect safety                                      |
| `tests/billing.test.ts`             | Seat counting/limits, mock adapter contract                            |
| `tests/billing-edge-cases.test.ts`  | Seat upgrades/downgrades, adapter failures, boundary conditions        |
| `tests/rbac-boundary.test.ts`       | Cross-org isolation, rank escalation, hierarchy enforcement            |
| `tests/service-integration.test.ts` | Full multi-step flows through the service layer                        |
| `tests/audit.test.ts`               | Append-only audit, metadata, pagination, history survival              |
| `tests/smoke.test.ts`               | Build verification                                                     |
| `tests/edge-cases.test.ts`          | Malformed input, normalization, boundary conditions across services    |
| `tests/a11y-markup.test.ts`         | WCAG markup contract read off the route markup                         |
| `tests/csrf-cookie.test.ts`         | Single-sourced session-cookie options; no client-bundle exposure       |
| `tests/mcp.test.ts`                 | MCP protocol, tools and stdio transport                                |
| `tests/defect-regressions.test.ts`  | The 2026-10-12 fixes: expired-session sweep, error mapping, hash shape |
| `tests/scrypt-upgrade.test.ts`      | Work factor matches OWASP; legacy hashes still verify                  |
| `tests/invite-route.test.ts`        | Invite actions are rate limited; acceptance failures are 400s          |
| `tests/sessions.test.ts`            | Your-sessions service: scope, revocation, audit entries                |
| `tests/sessions-route.test.ts`      | `/app/sessions` wiring; no client-supplied identity                    |
| `tests/coverage-gaps.test.ts`       | Non-constraint DB faults, lost invite race, unknown roles              |
| `tests/branch-closures.test.ts`     | `SESSION_TTL_DAYS`, hash shape checks, `createOrg` atomicity           |
| `tests/audit-export.test.ts`        | CSV round-tripping, formula-injection guard, export pagination bounds  |

## Environment Variables

| Variable               | Default  | Purpose                    |
| ---------------------- | -------- | -------------------------- |
| `DATA_DIR`             | `./data` | SQLite file location       |
| `MOCK_PLAN_SEATS`      | `3`      | Seat limit for MockBilling |
| `AUTH_FAILED_ATTEMPTS` | `5`      | Failed attempts per window |
| `AUTH_WINDOW_MS`       | `900000` | Sliding window (15 min)    |
| `SESSION_TTL_DAYS`     | `30`     | Session lifetime in days   |

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
6. If the action is self-service (no org role involved), derive the caller from the session token rather than accepting a user id
7. Add tests in `tests/`

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
5. For a multi-instance deploy, run `npm run db:migrate` once first — see `docs/deployment.md`

## Build & CI

- **Quality gates:** clean-room install of the built artifact (the clean-room artifact gate, release Step 0b — unzip to an empty dir, install with no cache, run the suite) + `npm test` + ≥95% line/branch/function/statement coverage enforced by `vitest.config.ts`. **No CI service is included** — `.github/workflows/` is stripped from the public proof layer by design.
- **Build:** `npm run build` (adapter-auto)
- **No external services required** for development or testing
