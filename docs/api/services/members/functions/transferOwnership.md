[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: transferOwnership()

> **transferOwnership**(`db`, `input`): `Promise`\<`void`\>

Transfer ownership to another member, stepping the actor down to `admin`.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### actorRole

`"owner"` \| `"admin"` \| `"member"`

The current owner's role.

#### actorUserId

`string`

The current owner's id.

#### orgId

`string`

The organization id.

#### targetUserId

`string`

The member who becomes the new owner.

## Returns

`Promise`\<`void`\>

## Remarks

Enforces the single-owner invariant: the organization must currently
have exactly one owner, which becomes the target while the actor becomes `admin`.

## Throws

with code `forbidden` when the permission is missing.

## Throws

with code `hierarchy_violation` when the target is the
actor, `no_membership` when the target is not a member, or `last_owner` when
the data is inconsistent (multiple owners).
