[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: getMembership()

> **getMembership**(`db`, `orgId`, `userId`): `Promise`\<\{ `createdAtMs`: `number`; `id`: `string`; `orgId`: `string`; `role`: `string`; `userId`: `string`; \}\>

Fetch a user's membership row for an organization, or `null` when none exists.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

### userId

`string`

The user id.

## Returns

`Promise`\<\{ `createdAtMs`: `number`; `id`: `string`; `orgId`: `string`; `role`: `string`; `userId`: `string`; \}\>

The matching membership row, or `null`.
