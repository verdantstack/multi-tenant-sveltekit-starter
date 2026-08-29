# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.2.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/releases/tag/v0.1.0
