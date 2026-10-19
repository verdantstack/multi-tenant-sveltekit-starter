[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: revokeOtherSessions()

> **revokeOtherSessions**(`db`, `input`): `Promise`\<`number`\>

Revoke every one of the caller's sessions except the one in use — "sign out
everywhere else", the response to a device that may have been left signed in.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### sessionToken

`string` \| `undefined`

The raw token from the session cookie; it is the one
session that survives.

## Returns

`Promise`\<`number`\>

The number of sessions revoked.

## Throws

with code `unauthenticated` when there is no live session.

## Remarks

`destroyAllSessions()` in `auth.ts` is the same delete without a count;
this one returns how many rows it removed, because the caller reports the number
to the user and writes it into the audit entry.
