# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.15] - 2026-10-12

### Added

- **Your sessions** — a `/app/sessions` screen where a signed-in user can see
  every device they are signed in on, end an individual session, or sign out
  everywhere else at once. Reachable from the app top bar.

  - `src/lib/server/services/sessions.ts` — `listOwnSessions()`,
    `revokeOwnSession()`, `revokeOtherSessions()`.
  - **Every function takes the session token, never a user id.** The user id is
    re-derived server-side from that token, and the `DELETE` is scoped to it, so a
    forged or misrouted session id cannot reach another account's rows. There is
    no client-supplied identity anywhere on the page to get wrong.
  - Revoking the session you are currently using is refused with a pointer to
    Sign out, rather than completing a request against a session it just killed.
  - Each revocation writes an append-only `session.revoked` (or
    `session.revoked_others`, with the count) row. Sessions belong to a user, not
    an organization, so these entries carry no `orgId` — which keeps them out of
    every organization's audit page while still leaving the record an incident
    review needs.

- `rateLimitedToFail()` in `lib/server/http.ts` — the 429 wording now lives
  beside `errorToFail()` instead of being written out inside the `/login` action,
  so every surface that consults a `RateLimiter` answers identically.

### Fixed

- **The scrypt work factor was below the standard its own comment cited.**
  `auth.ts` used `N = 16384, r = 8, p = 1` under the comment "OWASP-recommended
  scrypt parameters for interactive logins". OWASP's Password Storage Cheat Sheet
  gives a minimum CPU/memory cost of 2^17 at block size 8 and parallelism 1, and
  lists `2^17/p=1`, `2^16/p=2`, `2^15/p=3`, `2^14/p=5` and `2^13/p=10` as
  configurations of similar minimal defense. `2^14` is only paired with `p=5`, so
  the shipped value was neither the minimum nor any listed configuration, and the
  comment made a false claim about a named standard.

  The default is now `N = 2^17, r = 8, p = 1`. **`SCRYPT_MAXMEM` was added
  alongside it and is not optional**: scrypt needs `128 * N * r` bytes (128 MiB at
  this value) while Node defaults `maxmem` to 32 MiB and throws
  `ERR_CRYPTO_INVALID_SCRYPT_PARAMS` rather than allocating.

  Existing hashes are unaffected — `format()` encodes `scheme$N$r$p$salt$hash` and
  `verifyPassword()` reads the parameters back out of the stored value, so a row
  written under the old parameters keeps verifying and is only re-issued at the
  new cost when its owner next sets a password.
  `tests/scrypt-upgrade.test.ts` proves that path, including all five OWASP-listed
  configurations.

  The suite runs the production parameters rather than a weakened test-only value.
  That costs wall-clock — roughly 80s instead of 15s — and buys a suite that
  exercises what ships.

- **The invite page was an unlimited credential oracle.**
  `/invite/[token]`'s `loginAccept` and `signupAccept` actions verify passwords and
  create accounts with **no rate limiting at all**; the limiter existed only inside
  the `/login` action. Anyone holding a valid invite link had an unlimited
  password-guessing oracle against every account in the install, with none of the
  failed-attempt accounting the limiter exists to enforce. Both actions now check
  the key before spending any scrypt work, penalise failures, reset on success,
  and answer the shared 429.

- **`loginAccept` reported an explainable failure as an Internal Error.** It called
  `tryAccept()` outside any try/catch, so signing in on an expired, revoked or
  already-used link threw out of the action while the two sibling actions on the
  same page handled it — and the user was left holding a session cookie. It now
  returns the same 400 with the real message.

- **`cleanupExpiredSessions()` never deleted anything.** It matched
  `eq(expiresAtMs, Date.now())`, so it removed only sessions whose expiry was
  _exactly_ the current millisecond. Expired sessions accumulated without bound.
  The predicate is now `lt`, matching what `getUserBySessionToken()` already
  treated as expired.

- **`errorToFail()` contradicted its own documented contract.** The docstring
  promised a generic 500 for "anything unmapped or unexpected", but the
  implementation reached that branch only for values with no `code` at all —
  every other `{ code, message }` became a 400 carrying its raw message.
  better-sqlite3 attaches both to every `SqliteError`, so an internal fault was
  reported to the browser as a user-fixable 400 with schema table and column names
  in the body. It now maps an explicit allow-list of this kit's machine codes and
  answers a logged, generic 500 for anything else, so a new code that nobody
  registered fails closed.

- **`verifyPassword()` threw on a corrupt stored hash.** A value truncated after
  the salt left `hashB64` undefined and `Buffer.from(undefined, 'base64')` raised
  a `TypeError`; neither caller wraps the call in a try/catch, so one bad
  `password_hash` row turned every login attempt for that account into an
  unhandled 500 _and_ skipped the limiter's failure accounting. The field count
  and the scrypt parameters are now validated before use, so a malformed row is a
  failed verification — and a row claiming an enormous work factor is refused
  rather than made to allocate gigabytes on every login.

- **`createOrg()` was not atomic.** The organization row, the owner's membership
  and the audit entry were three independent statements; a failure between them —
  most easily the membership INSERT tripping the `users` foreign key — left an
  organization with no owner, which no read path can reach and nothing collects.
  They now run in one transaction.

### Fixed

- **The CSV export had no formula-injection guard.** `csvEscape()` implemented
  RFC 4180 quoting only. Spreadsheets treat a value beginning `=`, `+`, `-` or `@`
  as a **formula**, not text, so an exported cell could become a live
  `=HYPERLINK(...)` in the compliance officer's spreadsheet. Nothing in today's
  columns can start with one — `metadata_json` is JSON-wrapped, `actor_user_id`
  and `target_id` are UUIDs, `action` and `target_type` are server constants,
  `created_at` is an ISO timestamp — so this was unreachable in practice. It is
  fixed anyway, because the guarantee was resting on an argument about the current
  schema rather than on a property of the code: the first column a buyer adds from
  user input would have inherited the hole, and nothing would have failed.
  `neutralizeFormula()` now prefixes such values with an apostrophe, which keeps
  the text and round-trips on re-import.

  **Order matters and the wrong order is the natural one.** The guard runs on the
  _raw_ value, before quoting. Quoting first would leave the field starting with
  `"`, which matches no trigger character, so the canonical payload
  `=HYPERLINK("…")` — which necessarily contains a quote — would pass through
  untouched. `tests/audit-export.test.ts` pins exactly that payload.

- **`csvEscape()` did not quote on a bare carriage return.** A lone `\r` splits
  rows in some CSV parsers, so a metadata value containing one produced a record
  count that did not match the row count. `\r` now joins `\n` in the trigger set.

- **The audit exports had no pagination ceiling.** `limit` and `offset` were passed
  straight through, so one request could ask for the entire append-only log —
  unbounded memory on exactly the table designed to grow forever. `MAX_EXPORT_ROWS`
  (10 000) and `clampExportPage()` now floor `limit` at 1 and `offset` at 0 and cap
  the page, applied to both `exportAuditCsv()` and `exportAuditJson()`.

- **`exportAuditJson()` aborted the whole export on one corrupt metadata row.**
  `JSON.parse()` threw on anything unparseable. The audit log is append-only with
  no UPDATE path, so such a row can never be repaired — throwing denied the buyer
  every other event in the file, including the ones they needed. A row that will
  not parse is now reported as its raw string.

### Changed

- Test count 357 → 475. Coverage is 100% on statements, branches, functions and
  lines, measured with `npm run test:coverage`.
- `npm run format:check` now passes. It did not before this pass: 24 files were
  unformatted, including five documentation files.

## [0.2.14] - 2026-10-04

## [0.2.13] - 2026-10-04

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

[0.2.15]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.14...v0.2.15
[0.2.14]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.13...v0.2.14
[0.2.13]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.13...v0.2.13
[0.2.12]: https://github.com/verdantstack/multi-tenant-sveltekit-starter/compare/v0.2.11...v0.2.13
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
