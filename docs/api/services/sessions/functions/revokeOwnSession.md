[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: revokeOwnSession()

> **revokeOwnSession**(`db`, `input`): `Promise`\<`void`\>

Revoke one of the caller's own sessions.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### sessionToken

`string` \| `undefined`

The raw token from the session cookie.

#### targetSessionId

`string`

The `sha256(token)` id of the session to revoke.

## Returns

`Promise`\<`void`\>

## Remarks

Scoped to the derived `userId`, so a session id belonging to anyone
else deletes nothing and is reported the same way a missing one is. Revoking
the session you are currently using is refused with a pointer to Sign out,
because the request would otherwise complete against a session it had just
invalidated.

## Throws

with code `unauthenticated` when there is no live session,
or `not_your_session` when the target is missing, already ended, not the
caller's, or is the session in use.
