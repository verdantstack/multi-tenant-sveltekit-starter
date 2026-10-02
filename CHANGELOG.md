# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.12] - 2026-10-02

### Fixed

- README version claim. The `**Version**` line, the version badge and the
  machine-readable `version:` field all still read `0.2.11`'s predecessor after the
  previous release, so the published proof repo stated a version that did not match
  its own release tag. All three forms now track `package.json`.


## [0.2.11] - 2026-10-02

### Added

- `src/lib/server/mcp/` — an MCP server exposing the service layer to a coding
  agent over stdio. Four read tools: `list_orgs`, `list_members`,
  `list_pending_invites` and `list_audit_log`, all backed by the same services
  the app uses, all taking a `Db` (better-sqlite3 + Drizzle).

  - **Read-only by design.** These tools are called by a language model, and a
    model can be steered into calling them by text it has just read — a prompt
    injection hidden in an audit-log string could otherwise reach a mutating
    call. Reads cannot destroy state, so reads are the first surface exposed.
  - **No SDK.** MCP over stdio is JSON-RPC 2.0. Implementing it keeps this
    feature dependency-free and shows the protocol rather than hiding it.
  - **Both protocol shapes.** The 2026-07-28 revision dropped the mandatory
    `initialize` handshake for a stateless core carrying `protocolVersion` in
    `_meta`; older clients still open with `initialize`. The server accepts
    both and names the versions it implements when asked for one it does not.
  - **Tool failures are results, not protocol errors** (`isError: true` with a
    readable message), so a model can correct its call and retry.
  - `npm run mcp` starts it. Credentials come from whatever the app already
    uses — no new environment variables.
  - Lives inside `src/lib/server/`, so it counts toward the coverage
    threshold. The module is at 100% statement, branch, function and line
    coverage; `cli.ts` is excluded with the reason recorded in
    `vitest.config.ts`, and the transport is covered in-process.
  - The stdio transport is serialised deliberately: replies go out in the
    order requests were read, so a client never gets two responses swapped.

- `tests/mcp.test.ts` — protocol, tool and transport coverage. Test count
  326 → 357.



## [0.2.10] - 2026-10-02

### Added

- `tests/csrf-cookie.test.ts` — real client-bundle exposure guard. Walks every module SvelteKit also
  runs in the browser (`.svelte`, `+page.ts`, `+layout.ts`) and fails if any of them imports
  `$lib/server/*` auth code or reads the session cookie from `document.cookie`. This replaces a test
  that was _named_ for this guard while asserting only `maxAge`.

### Changed

- The `sameSite` pin is renamed `pins sameSite to 'lax' so the documented threat model stays true`.
  The previous name claimed the test "documents the limits" of `lax`; it never did. It pins the
  _premise_ of the documented threat model (change the cookie option and the analysis stops
  describing the code, so fail and revisit). The two documented limits themselves are browser
  behaviour and are not unit-tested, and the test's docblock now says so.

### Fixed

- A test whose name claimed a security property it did not check. `never exposes the session token
to a public module` asserted `maxAge > 0`. Split into `gives the session cookie a positive
lifetime` (what it actually checked) and the new, real exposure guard.

### Notes

- 323 tests across 14 suites, coverage 98.84 / 95.62 / 100 / 99.17. `svelte-check` clean.
- The exposure guard is falsifiable: adding a `.svelte` file that imports `$lib/server/auth` makes
  it fail with the offending path in the message.

## [0.2.8] - 2026-09-20

### Added

- **Dinh Fire Lamp theme** applied across the app UI and docs — Bạc Ngà (ivory) light default with an optional Rừng Đêm (forest-night) dark palette, tokenized per the shared design spec (Georgia serif headings, 18px radii, 60-30-10).

### Fixed

- Light-mode `--faint` text color corrected to the spec value (`#97897a`; a dark-mode value had been used, dimming secondary text too far in light mode).

### Docs

- Screenshot gallery refreshed — every capture re-taken against the themed live demo (owner dashboard, invite flow, seat updates, RBAC denial, audit trail; 298 tests).

## [0.2.7] - 2026-09-13

### Docs

- Suite tables completed to match the shipped 13 test files: `AGENTS.md`, `docs/testing.md`, and README status now list every suite (added `billing-edge-cases`, `rbac-boundary`, `service-integration`, `edge-cases`) with measured per-file counts (298 tests total).

## [0.3.0] - 2026-09-10

### Tests

- 298 tests (was 240): +58 new tests covering e2e billing flows (seat upgrades/downgrades, adapter failures, boundary conditions), RBAC boundary cases (cross-org isolation, rank escalation, hierarchy enforcement), full multi-step service-integration flows, and auth edge cases. Suite grown to 13 files.

## [0.2.4] - 2026-09-09

### Added

- **Docker support**: `Dockerfile` (multi-stage Node 24 Alpine build) and `docker-compose.yml` with persistent SQLite volume for container deployments.
- **Deployment docs**: `docs/deployment.md` — comprehensive deployment guide covering Docker, VPS, Cloudflare Pages, Vercel, Fly.io, and Postgres swap path.
- **Usage-based billing guide**: `docs/ai-billing.md` — adapter pattern for AI token usage tracking, metered billing, and usage-based pricing.
- **`.dockerignore`**: Build context exclusions for cleaner Docker builds.

## [0.2.3] - 2026-09-08

### Added

- **Password strength validation**: `checkPasswordStrength()` now enforces uppercase, lowercase, and digit requirements (not just minimum length). Returns `{ ok, reasons }` for UI feedback.
- **Session management**: `listSessions()`, `destroyAllSessions(exceptToken?)`, `cleanupExpiredSessions()` for security features like "log out everywhere" and session listing.
- **Configurable session TTL**: `SESSION_TTL_DAYS` environment variable (default 30) for compliance scenarios requiring shorter sessions.
- **Audit log export**: `exportAuditCsv()` and `exportAuditJson()` for compliance buyers who need to export their audit trail. CSV includes proper escaping; JSON includes ISO timestamps and parsed metadata.
- **Billing guard**: `assertSeatAvailable()` now blocks `past_due` and `canceled` subscriptions from adding new seats.

### Fixed

- **`createUser` error handling**: catch block now only catches unique constraint violations (`SQLITE_CONSTRAINT`, `SQLITE_CONSTRAINT_UNIQUE`, Postgres `23505`) instead of silently swallowing all DB errors as `email_taken`.

### Tests

- 240 tests (was 204): +36 new tests covering password strength, session management, billing guard, error mapping with actual Error subclasses, audit export, and audit pagination edge cases.

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

[0.2.12]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.11...v0.2.12
[0.2.11]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.10...v0.2.11
[0.2.10]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.10...v0.2.10
[0.2.10]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.8...v0.2.10
[0.2.8]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.3.0...v0.2.7
[0.3.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.5...v0.3.0
[0.2.4]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.3...v0.2.4
[0.2.2]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/releases/tag/v0.1.0
