[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: getOrgForUser()

> **getOrgForUser**(`db`, `userId`, `orgId`): `Promise`\<\{ `org`: \{ `createdAtMs`: `number`; `id`: `string`; `name`: `string`; `slug`: `string`; \}; `role`: `"owner"` \| `"admin"` \| `"member"`; \} \| `null`\>

Get an organization as seen by a specific user, scoped to membership.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user id.

### orgId

`string`

The organization id.

## Returns

`Promise`\<\{ `org`: \{ `createdAtMs`: `number`; `id`: `string`; `name`: `string`; `slug`: `string`; \}; `role`: `"owner"` \| `"admin"` \| `"member"`; \} \| `null`\>

The org plus the caller's role within it, or `null` when the caller
is not a member.
