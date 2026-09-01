# Architecture

## Layering

```mermaid
graph TD
    subgraph ROUTES["🖥️ Routes"]
        R["+page.server.ts<br/>parse form → call service → fail/redirect"]
    end

    subgraph SERVICES["⚙️ Services"]
        S["orgs · members · invites<br/>domain logic · pure functions<br/>Db passed in"]
    end

    subgraph POLICY["🛡️ Policy & Seams"]
        RBAC["rbac.ts<br/>role hierarchy · permissions"]
        BILLING["billing/<br/>BillingAdapter interface"]
        RATELIMIT["ratelimit.ts<br/>RateLimiter interface"]
    end

    subgraph INFRA["🗄️ Infrastructure"]
        DB["db/index.ts<br/>better-sqlite3 + drizzle<br/>+ auto migrations"]
    end

    R -->|"call service"| S
    S -->|"requirePermission()"| RBAC
    S -->|"assertSeatAvailable()"| BILLING
    R -->|"pre-check key"| RATELIMIT
    S -->|"query/mutate"| DB

    classDef route fill:#e3f2fd,stroke:#1565c0,color:#0d47a1
    classDef service fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20
    classDef policy fill:#fff3e0,stroke:#ef6c00,color:#e65100
    classDef infra fill:#fce4ec,stroke:#c62828,color:#b71c1c

    class R route
    class S service
    class RBAC,BILLING,RATELIMIT policy
    class DB infra
```

Rules:

1. **Routes never touch the database directly** except to fetch read models via services. All writes go through a service so audit entries and permission checks can't be skipped.
2. **Services are framework-free** — they import nothing from `@sveltejs/kit`. That's what makes them unit-testable with `createDb(':memory:')` and no SvelteKit runtime.
3. **Every mutating service call re-derives authority from arguments**: callers pass `actorRole`, fetched fresh inside the same request (`requireRole()` re-reads the membership row). No trust in client-submitted role fields.
4. **Errors carry machine codes** (`AuthError`, `RbacError`, `InviteError`, `MemberError`, `OrgError`, `BillingError`). One mapper — `lib/server/http.ts:errorToFail()` — turns them into HTTP responses.

## Concurrency notes

- **Single-use invites** don't rely on read-then-write. Acceptance performs an `UPDATE ... WHERE id = ? AND accepted_at_ms IS NULL AND revoked_at_ms IS NULL RETURNING id`; zero rows updated = someone got there first. Safe under concurrent clicks without explicit transactions.
- **SQLite via better-sqlite3** is synchronous and serialized per process; WAL mode keeps readers unblocked. For multi-instance deployment, move to Postgres (schema is portable; see "Swapping the database").

## Sessions

```mermaid
sequenceDiagram
    participant Browser
    participant Route as Route (+page.server.ts)
    participant Auth as auth.ts
    participant DB as db/sessions

    Browser->>Route: POST /login (email + password)
    Route->>Auth: verifyPassword(password, hash)
    Auth-->>Route: ✅ valid
    Route->>Auth: createSession(userId)
    Auth->>DB: INSERT sha256(token), user_id, expiry
    Auth-->>Route: raw token
    Route-->>Browser: Set-Cookie: token (httpOnly, sameSite=lax, secure)
    Note over Browser,DB: DB stores only sha256(token) — leak-safe

    Browser->>Route: GET /dashboard (cookie)
    Route->>Auth: getUserBySessionToken(token)
    Auth->>DB: SELECT user WHERE sha256(token) = PK AND expiry > now
    DB-->>Auth: user row
    Auth-->>Route: user
    Route-->>Browser: 200 OK
```

- Token: 32 random bytes, hex. Cookie holds the raw token (`httpOnly`, `sameSite=lax`, `secure` in prod).
- DB stores only `sha256(token)` as PK → a database leak doesn't yield usable sessions.
- Expiry: fixed 30 days v0.1 (sliding expiry is a deliberate non-goal until real usage data exists).

## Audit design

`audit_log.orgId`/`actorUserId` are plain text with an index, **not foreign keys** — history must survive member removal and (future) org deletion. Metadata is a JSON string; writers decide what goes in. The raw invite token is never audited.

## Swapping the database

1. Replace `better-sqlite3` driver + `drizzle-orm/better-sqlite3` with e.g. `drizzle-orm/node-postgres` in `db/index.ts`.
2. Adjust column types in `schema.ts` (`integer` ms timestamps → `timestamp`), regenerate migrations.
3. Services compile unchanged — they only use the shared `Db` type and query-builder calls.

## Auth rate limiting

```mermaid
flowchart LR
    REQ["HTTP Request<br/>POST /login"] --> CHECK{"RateLimiter<br/>.check(key)"}
    CHECK -->|"❌ blocked"| DENY["429 Too Many<br/>Requests"]
    CHECK -->|"✅ allowed"| SCRYPT["scrypt verify<br/>(expensive)"]
    SCRYPT -->|"success"| OK["200 + session"]
    SCRYPT -->|"failure"| FAIL["401 Unauthorized"]
    FAIL --> RECORD["RateLimiter<br/>.record(key)"]
    FAIL -->|"subsequent"| CHECK

    style CHECK fill:#fff3e0,stroke:#ef6c00
    style DENY fill:#ffcdd2,stroke:#c62828
    style OK fill:#e8f5e9,stroke:#2e7d32
```

`lib/server/ratelimit.ts` ships a `RateLimiter` interface (same seam philosophy as billing) with one concrete implementation: a sliding-window **failed-attempt** limiter. Only failures are recorded; success calls `reset()`. The login action pre-checks the key *before* any scrypt work, so blocked floods cost ~nothing.

Wiring: `login/+page.server.ts` — key is `login:<client-ip>:<normalized-email>` for logins, `signup:<client-ip>` for signups. Tune with env: `AUTH_FAILED_ATTEMPTS` (default 5), `AUTH_WINDOW_MS` (default 900000 = 15 min). Blocked requests get HTTP 429 with an approximate retry window and no information about attempts remaining.

Scope honesty: the shipped limiter is **in-memory and per-process**. It stops single-source credential stuffing against a single instance. For multi-instance deployments implement the interface against a shared store (Redis or the SQL DB) — no other code changes needed.

## Deliberate v0.2 limits

- Rate limiting is per-process (above) — shared-store implementation deferred until a real deployment topology exists.
- Invite links work for whoever holds them; optional `email` field is a human note, not enforcement. Email-enforced invites need email delivery, which requires a transactional email provider.
- Single-process seat counting: fine at demo scale; when Postgres lands, wrap claim+count in one transaction.
