# RBAC model

## Roles

`owner > admin > member` (rank 2 > 1 > 0)

```mermaid
graph LR
    subgraph HIERARCHY["Role Hierarchy"]
        direction LR
        OWNER["👑 <b>owner</b><br/>rank 2"] -->|"mayActOn<br/>mayGrant"| ADMIN["⚡ <b>admin</b><br/>rank 1"]
        ADMIN -->|"mayActOn<br/>mayGrant"| MEMBER["👤 <b>member</b><br/>rank 0"]
    end

    OWNER -.-|"❌ cannot act on self"| OWNER
    ADMIN -.-|"❌ cannot act on<br/>admin or owner"| ADMIN
    MEMBER -.-|"❌ cannot grant<br/>any role"| MEMBER

    classDef owner fill:#f9a825,stroke:#f57f17,color:#000
    classDef admin fill:#42a5f5,stroke:#1565c0,color:#fff
    classDef member fill:#66bb6a,stroke:#2e7d32,color:#fff

    class OWNER owner
    class ADMIN admin
    class MEMBER member
```

## Capability matrix

| Permission | owner | admin | member |
|---|:-:|:-:|:-:|
| org.view | ✓ | ✓ | ✓ |
| members.view | ✓ | ✓ | ✓ |
| members.invite | ✓ | ✓ | — |
| members.remove | ✓ | ✓* | — |
| members.role.set | ✓ | ✓* | — |
| invites.revoke | ✓ | ✓ | — |
| audit.view | ✓ | ✓ | — |
| billing.manage | ✓ | — | — |
| ownership.transfer | ✓ | — | — |

\* subject to hierarchy rules below.

The matrix lives in exactly one place: `src/lib/server/rbac.ts` (`MATRIX`). UI gating reads a server-computed `permissions` record; it is cosmetic only.

## Hierarchy rules (the part buyers get wrong)

Enforced in `members.ts` / `invites.ts` on every action:

1. **Act downward only** — `mayActOn(actor, target)` requires `rank(actor) > rank(target)`. An admin cannot touch another admin or the owner.
2. **Grant strictly below yourself** — `mayGrant(actor, granted)` requires `rank(actor) > rank(granted)`. Only owners mint admins; admins mint members. Nobody grants their own rank, ever.
3. **No self-modification** — you cannot change your own role, remove yourself via remove-member (use *Leave*), or transfer ownership to yourself.
4. **Single-owner invariant** — `transferOwnership` sets target→owner and actor→admin together; leaving while still the sole owner is refused (`last_owner`).

## Enforcement points

```mermaid
flowchart TD
    REQ["Request arrives<br/>(session cookie only)"] --> LOAD{"getOrgForUser()"}
    LOAD -->|"null"| ERR404["404 Not Found"]
    LOAD -->|"membership row"| ROLE["Re-derive role<br/>from DB row"]

    ROLE --> READ{"Capability-gated<br/>read?"}
    READ -->|"yes"| PERM_READ["requirePermission()<br/>check MATRIX"]
    READ -->|"no"| SERVE_READ["Serve data"]
    PERM_READ -->|"✅ rank ≥ required"| SERVE_READ
    PERM_READ -->|"❌ rank < required"| ERR403["403 Forbidden"]

    ROLE --> ACTION{"Mutating<br/>action?"}
    ACTION -->|"yes"| PERM_ACTION["requirePermission()<br/>+ mayActOn()/mayGrant()"]
    ACTION -->|"no"| SERVE_READ
    PERM_ACTION -->|"✅ hierarchy OK"| WRITE["Write to DB<br/>+ audit entry"]
    PERM_ACTION -->|"❌ hierarchy violation"| ERR403

    classDef ok fill:#e8f5e9,stroke:#2e7d32
    classDef err fill:#ffcdd2,stroke:#c62828
    classDef check fill:#fff3e0,stroke:#ef6c00
    classDef entry fill:#e3f2fd,stroke:#1565c0

    class SERVE_READ,WRITE ok
    class ERR404,ERR403 err
    class ROLE,READ,PERM_READ,ACTION,PERM_ACTION check
    class REQ entry
```

- Page loads: `getOrgForUser()` returns null unless the caller has a membership row; layout turns that into a 404. Capability-gated reads re-check the matrix on top of membership — e.g. the audit log's load runs `requirePermission(role, 'audit.view')` and answers 403 below admin.
- Actions: `requireRole()` re-reads the membership fresh per request; each service then runs `requirePermission()` + hierarchy checks before any write.
- Result: forging requests with another user's role field fails; only the session cookie matters, and capabilities derive from DB state.

## Test coverage

`tests/rbac.test.ts` pins the matrix; `tests/orgs-members.test.ts` proves the hierarchy end-to-end against a live schema, including the attempts that must fail.
