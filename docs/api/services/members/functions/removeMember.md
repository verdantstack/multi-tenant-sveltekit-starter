[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: removeMember()

> **removeMember**(`db`, `input`): `Promise`\<`void`\>

Remove a member from an organization, enforcing the permission and hierarchy rules.

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

#### orgId

`string`

The organization id.

#### targetUserId

`string`

The member being removed. Must not be the actor.

## Returns

`Promise`\<`void`\>

## Throws

with code `forbidden` when the permission is missing.

## Throws

with code `self_remove`, `no_membership`, or
`hierarchy_violation` for invalid targets.
