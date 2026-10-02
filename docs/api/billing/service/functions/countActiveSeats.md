[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: countActiveSeats()

> **countActiveSeats**(`db`, `orgId`): `Promise`\<`number`\>

Count the memberships (seats) currently used by an organization.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<`number`\>

The number of active members.
