# CLAUDE.md — Claude AI Context

> Context for Claude when working on this codebase.

## What This Is

A production-shaped B2B SaaS foundation for SvelteKit. Not a tutorial, not a boilerplate — a working implementation of multi-tenancy, RBAC, seat billing, and audit logging with 52 tests.

## The Mental Model

Think of this as three layers:

1. **Routes** (thin) — parse forms, call services, handle errors
2. **Services** (domain logic) — pure functions that accept a `Db` and do real work
3. **Infrastructure** (db, auth, rbac, billing) — pluggable seams, not monoliths

The key insight: **services never import from SvelteKit**. This makes them testable with `:memory:` SQLite and portable to any framework.

## When Modifying Code

### If you're changing behavior
1. Write the test first (or alongside)
2. Service layer is where logic lives — not in routes
3. Every write must go through `requirePermission()` + `requireRole()`
4. Every write must produce an audit entry in the same call

### If you're changing the schema
1. Edit `src/lib/server/db/schema.ts`
2. Run `npm run db:generate`
3. Review the generated SQL in `drizzle/`
4. Test that migrations apply cleanly

### If you're adding a new feature
1. Check `rbac.ts` — does it need a new permission?
2. Create service in `src/lib/server/services/`
3. Wire the route in `src/routes/`
4. Add to `errorToFail()` if new error types
5. Test the full flow HTTP-level in `tests/http.test.ts`

## Things That Will Bite You

- **Redirect swallowing:** `errorToFail()` must rethrow SvelteKit redirects, not swallow them. If you see a 500 after a successful action, check this.
- **RBAC hierarchy:** `mayActOn(actor, target)` requires `rank(actor) > rank(target)`. An admin cannot touch another admin. This is by design.
- **Last owner:** The code prevents the last owner from leaving or being removed. Don't remove this check.
- **Invite race conditions:** Single-use invites use conditional UPDATE, not read-then-write. Two concurrent clicks = exactly one winner. Don't "fix" this with transactions.
- **Audit is append-only:** There is no UPDATE or DELETE path for audit_log. Don't add one.

## Testing Philosophy

- Tests use `:memory:` SQLite — fast, isolated, no side effects
- Every test creates a fresh DB via `createDb(':memory:')`
- Tests exercise services directly AND HTTP-level flows
- The HTTP tests in `tests/http.test.ts` are the most important — they prove the full stack works

## Code Conventions

- TypeScript strict mode
- Error classes: `AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`
- Timestamps: milliseconds, UTC
- Database: better-sqlite3 (synchronous), Drizzle ORM
- No external services needed for dev or test
