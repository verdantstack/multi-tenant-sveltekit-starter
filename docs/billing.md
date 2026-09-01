# Billing wiring (seat-based, merchant-of-record)

## Why an adapter

```mermaid
graph TB
    subgraph APP["Application Code"]
        INVITE["acceptInvite()"]
    end

    subgraph SEAM["BillingAdapter Interface"]
        STYLE["getSubscriptionState()"]
        CHECKOUT["createCheckoutUrl()"]
    end

    subgraph MOCK["MockBillingAdapter (dev)"]
        M_STATE["always 'active'<br/>MOCK_PLAN_SEATS seats"]
        M_CHECK["returns null"]
    end

    subgraph FUTURE["Real MoR Adapter (production)"]
        F_STATE["webhook → subscriptions table"]
        F_CHECK["Lemon Squeezy / Paddle<br/>checkout session"]
    end

    INVITE -->|"assertSeatAvailable()"| STYLE
    STYLE --> MOCK
    STYLE -.->|"swap one line"| FUTURE
    CHECKOUT --> MOCK
    CHECKOUT -.->|"swap one line"| FUTURE

    classDef app fill:#e3f2fd,stroke:#1565c0
    classDef seam fill:#fff3e0,stroke:#ef6c00
    classDef mock fill:#e8f5e9,stroke:#2e7d32
    classDef future fill:#f3e5f5,stroke:#7b1fa2

    class INVITE app
    class STYLE,CHECKOUT seam
    class M_STATE,M_CHECK mock
    class F_STATE,F_CHECK future
```

Checkout runs through a **Merchant of Record** (Lemon Squeezy / Paddle / Payhip are the usual candidates): the MoR becomes the legal seller of record and handles sales tax, so you don't register as a merchant in every jurisdiction your customers live in. Which MoR you pick is swappable by design — the product must not depend on that choice, so all payment knowledge sits behind:

```ts
// src/lib/server/billing/adapter.ts
export interface BillingAdapter {
	readonly name: string;
	getSubscriptionState(orgId: string): Promise<SubscriptionState>; // status + planSeats
	createCheckoutUrl(input: { orgId: string; seats: number }): Promise<string | null>;
}
```

Everything else in the codebase consumes the interface. Today it's satisfied by `MockBillingAdapter` (every org "active", `MOCK_PLAN_SEATS` seats, default 3). Wiring point: `src/lib/server/billing/index.ts` — swap one line, change nothing else.

## Where enforcement happens

```mermaid
flowchart LR
    INVITE["Owner sends<br/>invite"] --> ACCEPT["Member clicks<br/>invite link"]
    ACCEPT --> COUNT["COUNT(memberships)<br/>for org"]
    COUNT --> GATE{"seatsUsed<br/>≥ planSeats?"}
    GATE -->|"❌ at limit"| BLOCK["BillingError<br/>'upgrade or free<br/>a seat'"]
    GATE -->|"✅ seats available"| CLAIM["Single-use<br/>UPDATE (atomic)"]
    CLAIM --> AUDIT["audit_log entry<br/>+ membership created"]

    style GATE fill:#fff3e0,stroke:#ef6c00
    style BLOCK fill:#ffcdd2,stroke:#c62828
    style AUDIT fill:#e8f5e9,stroke:#2e7d32
```

Exactly one gate: **invite acceptance** (`assertSeatAvailable`). Inviting beyond the seat count is allowed on purpose — the limit surfaces at accept time as an actionable error ("upgrade or free a seat"), which is also how most incumbents behave and what beta testers expect to see.

Counting rule v0.1: `seatsUsed = COUNT(memberships)` for the org. Statuses other than `active`/`trialing` block joins entirely.

## What the real adapter must do

1. `getSubscriptionState`: map MoR subscription webhooks → `{status, planSeats}` rows keyed by orgId (add a `subscriptions` table; keep the interface).
2. `createCheckoutUrl`: create a checkout session for `plan-seats` product with `orgId` in passthrough metadata.
3. Webhook endpoint (new route, outside auth guard): verify signature → update local row. Never trust client-side success redirects for entitlements.
4. Keep `MockBillingAdapter` as the default under `NODE_ENV=development` so tests/dev stay hermetic.
