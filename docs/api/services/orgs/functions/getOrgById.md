[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: getOrgById()

> **getOrgById**(`db`, `orgId`): `Promise`\<\{ `createdAtMs`: `number`; `dpaAcceptedAtMs`: `number` \| `null`; `id`: `string`; `name`: `string`; `regionCode`: `string`; `slug`: `string`; \}\>

Fetch an organization by id without a membership check.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<\{ `createdAtMs`: `number`; `dpaAcceptedAtMs`: `number` \| `null`; `id`: `string`; `name`: `string`; `regionCode`: `string`; `slug`: `string`; \}\>

The organization row, or `null` when it does not exist.
