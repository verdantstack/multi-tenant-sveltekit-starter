[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: createInvite()

> **createInvite**(`db`, `input`): `Promise`\<\{ `expiresAtMs`: `number`; `id`: `string`; `token`: `string`; \}\>

Create an invitation for a user to join an organization.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

The acting user's role.

#### actorUserId

`string`

The acting user's id.

#### email?

`string`

Optional pre-committed invitee email (stored on the invite).

#### orgId

`string`

The organization id.

#### role

`string`

The role to grant; must be strictly below `actorRole`.

#### ttlDays?

`number`

Lifetime in days before the invite expires (default 7).

## Returns

`Promise`\<\{ `expiresAtMs`: `number`; `id`: `string`; `token`: `string`; \}\>

The invite id, the raw sharing token, and the expiry timestamp.

## Remarks

The actual permission is `members.invite`; inviting beyond the current
seat count is permitted, with the limit enforced only at accept time. The raw
token is returned to the caller and is never stored.

## Throws

with code `forbidden`, `bad_role`, or `hierarchy_violation`
when the actor lacks permission or the requested role is invalid/not grantable.
