[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: setMemberRole()

> **setMemberRole**(`db`, `input`): `Promise`\<`void`\>

Change a member's role, enforcing the permission and hierarchy rules.

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

#### role

`string`

The new role; must be a known role strictly below `actorRole`.

#### targetUserId

`string`

The member whose role is being changed.

## Returns

`Promise`\<`void`\>

## Throws

with code `forbidden` or `bad_role` when the permission is
missing or the role is unknown.

## Throws

with code `hierarchy_violation` or `no_membership` when
the target is self, a peer/superior, or not a member.
