[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: listMembers()

> **listMembers**(`db`, `orgId`): `Promise`\<[`MemberRow`](../type-aliases/MemberRow.md)[]\>

List all members of an organization with their roles.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<[`MemberRow`](../type-aliases/MemberRow.md)[]\>

An array of `MemberRow`.
