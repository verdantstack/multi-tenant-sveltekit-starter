[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: listOrgsForUser()

> **listOrgsForUser**(`db`, `userId`): `Promise`\<`object`[]\>

List the organizations a user belongs to, each with the user's role.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user id.

## Returns

`Promise`\<`object`[]\>

An array of `{ id, name, slug, role }` for every organization the
user is a member of.
