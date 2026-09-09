[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: assertSeatAvailable()

> **assertSeatAvailable**(`db`, `orgId`, `billing`): `Promise`\<\{ `planSeats`: `number`; `seatsUsed`: `number`; \}\>

The one place seat limits are enforced: joining (invite acceptance).

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

### billing

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

The billing adapter describing the plan.

## Returns

`Promise`\<\{ `planSeats`: `number`; `seatsUsed`: `number`; \}\>

The seats used and the plan's paid seat count.

## Remarks

Invite creation is NOT limited — inviting beyond seats is allowed and
the limit surfaces at accept time with a clear, actionable error.

## Throws

with code `subscription_required` when the org has no
active subscription, or `seat_limit` when no seats are free.
