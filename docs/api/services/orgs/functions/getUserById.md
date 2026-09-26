[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: getUserById()

> **getUserById**(`db`, `userId`): `Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

Fetch a user's public profile fields by id.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user id.

## Returns

`Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

The user's id, email, and name, or `null` when not found.
