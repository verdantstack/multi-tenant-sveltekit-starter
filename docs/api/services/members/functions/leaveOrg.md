[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: leaveOrg()

> **leaveOrg**(`db`, `input`): `Promise`\<`void`\>

Remove the acting user from an organization on their own initiative.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### orgId

`string`

The organization id.

#### userId

`string`

The member leaving.

## Returns

`Promise`\<`void`\>

## Remarks

Enforces the single-owner invariant: an owner cannot leave while they
are the last owner.

## Throws

with code `no_membership` when the user is not a member,
or `last_owner` when a sole owner tries to leave.
