[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: revokeInvite()

> **revokeInvite**(`db`, `input`): `Promise`\<`void`\>

Revoke a pending invite so it can no longer be accepted.

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

#### inviteId

`string`

The invite id to revoke.

#### orgId

`string`

The organization id (scoping safeguard).

## Returns

`Promise`\<`void`\>

## Remarks

Requires `invites.revoke`. The update is conditional so already-used
or already-revoked invites cannot be revoked again.

## Throws

with code `forbidden` when the permission is missing.

## Throws

with code `invalid_token` when the invite is missing,
already used, or already revoked.
