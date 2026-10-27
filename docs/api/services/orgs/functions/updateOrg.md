[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: updateOrg()

> **updateOrg**(`db`, `orgId`, `userId`, `rawName`): `Promise`\<`void`\>

List the organizations a user belongs to, each with the user's role.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

### userId

`string`

The user id.

### rawName

`string`

## Returns

`Promise`\<`void`\>

An array of `{ id, name, slug, role }` for every organization the
user is a member of.
