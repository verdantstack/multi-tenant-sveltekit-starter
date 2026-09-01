[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: createSession()

> **createSession**(`db`, `userId`): `Promise`\<`string`\>

Issue a new session token for a user.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The id of the user to create the session for.

## Returns

`Promise`\<`string`\>

The raw session token to place in the browser cookie.

## Remarks

Sessions are database-backed and revocable. Only `sha256(token)` is
stored; the raw token is returned here and lives exclusively in the cookie.
