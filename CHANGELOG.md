# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- README/AGENTS metadata reconciled to the actual release (v0.2.2, 204 tests); version-history table in `docs/versioning.md` extended; internal process reference removed from `docs/architecture.md`.

### Added
- **In-repo API reference tooling**: `npm run docs:api` (typedoc) and `npm run docs:api:check` (regenerate + fail on drift), pinned typedoc 0.28.20 + typedoc-plugin-markdown 4.6.2, enforced in CI and the release pipeline.

## [0.2.2] - 2026-08-30

### Added
- **Source documentation (TSDoc)**: every exported symbol on the public API surface now carries a doc comment — parameter/return/throws contracts, the RBAC hierarchy (`mayActOn`/`mayGrant`), the typed error codes, schema tables, and the swappable `BillingAdapter`/`RateLimiter` seams. Comments only — no behavior, signature, or formatting change; all 204 tests still pass.
- **Generated public API reference**: `docs/api/` — a TypeDoc-generated reference for the full `src/lib/server` surface (auth, rbac, db, services, billing, http, ratelimit). Ships with the kit; regenerated from source so it cannot drift.
- **Docs gate (CI + release pipeline)**: `npm run docs:api:check` in CI and a `gen-api-docs` check in the release pipeline now fail if any exported symbol goes undocumented or if `docs/api` falls out of sync with the source.

## [0.2.1] - 2026-08-29

### Added
- **Audit suite**: `tests/audit.test.ts` — append-only writer (no update/delete path), metadata round-trip, null handling, newest-first pagination, history surviving member removal
- **Billing suite**: `tests/billing.test.ts` — per-org seat counting, `assertSeatAvailable` (at-limit + no-subscription), mock adapter contract + `MOCK_PLAN_SEATS` env override
- **Auth edge cases**: expired sessions rejected at read time; display-name fallback to email prefix
- **Org/invite edges**: unique URL-safe slug generation, member-only org reads, multi-owner transfer guard, invite default TTL + recipient-email normalization, raw token never audited, member-revoke forbidden
- **Documentation**: `docs/testing.md` — testing philosophy, suite layout, patterns, gotchas

### Changed
- Test suite grown from 52 to **204 tests across 9 suites**
- README/AGENTS/CLAUDE test counts and suite tables updated

## [0.2.0] - 2026-08-26

### Added
- **Rate limiting**: Sliding-window failed-attempt limiter on login/signup
  - `RateLimiter` seam (`src/lib/server/ratelimit.ts`)
  - Configurable via `AUTH_FAILED_ATTEMPTS` (default: 5) and `AUTH_WINDOW_MS` (default: 900000ms/15min)
  - 429 response with approximate retry window
  - Pre-check before scrypt hashing (attacker pays the cost, not you)
  - Verified over HTTP: 400→400→429→recovery
- 8 new unit tests for sliding-window semantics including eviction cap

### Fixed
- **Redirect swallowing bug**: Form actions that redirect from inside try/catch now propagate SvelteKit's redirect instead of returning a false 500 after side effects have committed
  - Fixed at `errorToFail()` choke point
  - 4 regression tests added in `tests/http.test.ts`
  - Full flow proven over HTTP end-to-end

### Changed
- Test count increased from 40 to 52
- Rate limiter documented in `docs/architecture.md` with multi-instance guidance

## [0.1.0] - 2026-08-26

### Added
- **Authentication**: Email+password with scrypt hashing, DB-backed revocable sessions, hashed session tokens
- **Organizations**: Create, slug, owner bootstrap
- **Invites**: Single-use hashed tokens, 7-day expiry, revoke, atomic claim
- **RBAC**: `owner > admin > member` hierarchy with capability matrix enforced server-side on every action
- **Billing**: `BillingAdapter` interface + deterministic `MockBillingAdapter` (seat limits enforced at join time)
- **Audit log**: Append-only by construction (no UPDATE/DELETE path exists)
- **Testing**: 40 passing tests covering auth, matrix, hierarchy, invite lifecycle, seat limits
- **CI**: GitHub Actions workflow (install → test → check → build)
- **Documentation**: Architecture, RBAC, billing, license docs
- **Screenshots**: S1–S8 captured from running app
- **Demo GIFs**: G1 (invite flow), G2 (RBAC denial)

### Design Principles
- Server-side enforcement everywhere (UI hides controls, but every load/action re-checks)
- Services are framework-free (import nothing from `@sveltejs/kit`)
- Every mutating service call re-derives authority
- Errors carry machine codes (`AuthError`, `RbacError`, etc.)
- One error mapper (`errorToFail()`)
- No ORM lock-in at service boundaries

[0.2.2]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/releases/tag/v0.1.0
