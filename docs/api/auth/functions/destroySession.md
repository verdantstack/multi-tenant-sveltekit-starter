[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: destroySession()

> **destroySession**(`db`, `token`): `Promise`\<`void`\>

Revoke a session, logging the user out.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### token

The raw session token; `undefined` is a no-op.

`string` | `undefined`

## Returns

`Promise`\<`void`\>
