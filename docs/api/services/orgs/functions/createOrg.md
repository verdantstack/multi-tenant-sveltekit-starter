[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: createOrg()

> **createOrg**(`db`, `userId`, `rawName`): `Promise`\<\{ `createdAtMs`: `number`; `id`: `` `${string}-${string}-${string}-${string}-${string}` ``; `name`: `string`; `slug`: `string`; \}\>

Create an organization and make `userId` its first owner.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The id of the user creating the organization.

### rawName

`string`

The organization name; trimmed and validated to 2–80 characters.

## Returns

`Promise`\<\{ `createdAtMs`: `number`; `id`: `` `${string}-${string}-${string}-${string}-${string}` ``; `name`: `string`; `slug`: `string`; \}\>

The created organization row.

## Remarks

A random suffix is appended to the slug to keep it unique. The caller
is automatically inserted as a membership with role `owner`.

## Throws

with code `bad_name` when the name is out of range.
