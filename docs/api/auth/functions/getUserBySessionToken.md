[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: getUserBySessionToken()

> **getUserBySessionToken**(`db`, `token`): `Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \} \| `null`\>

Resolve a session token to the authenticated user, if any.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### token

The raw session token from the cookie; `undefined` yields `null`.

`string` | `undefined`

## Returns

`Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \} \| `null`\>

The user's id, email, and name, or `null` when not authenticated.

## Remarks

Looks up the session by hashing the token, and returns `null` for a
missing, expired, or malformed token — never the raw token.
