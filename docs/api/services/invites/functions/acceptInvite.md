[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: acceptInvite()

> **acceptInvite**(`db`, `input`): `Promise`\<\{ `orgId`: `string`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \}\>

Atomically claim a single-use invite and add the user as a member.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### billing

[`BillingAdapter`](../../../billing/adapter/interfaces/BillingAdapter.md)

The billing adapter used to enforce seat limits.

#### token

`string`

The raw invite token.

#### userId

`string`

The id of the user accepting the invite.

## Returns

`Promise`\<\{ `orgId`: `string`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; \}\>

The joined org's id, name, and the granted role.

## Remarks

The UPDATE's WHERE clause is the concurrency gate, so two people
hitting the same link cannot both get in. A seat is also checked and consumed
against the org's billing plan.

## Throws

with code `invalid_token`, `expired`, `revoked`,
`already_accepted`, or `already_member`.

## Throws

with code `subscription_required` or `seat_limit` when
the org has no active plan or no seats are free.
