[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: listOwnSessions()

> **listOwnSessions**(`db`, `input`): `Promise`\<[`OwnedSession`](../type-aliases/OwnedSession.md)[]\>

List the caller's own sessions, flagging the one they are currently using.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

The operation inputs.

#### sessionToken

`string` \| `undefined`

The raw token from the session cookie.

## Returns

`Promise`\<[`OwnedSession`](../type-aliases/OwnedSession.md)[]\>

Every session belonging to the caller, oldest first.

## Throws

with code `unauthenticated` when there is no live session.
