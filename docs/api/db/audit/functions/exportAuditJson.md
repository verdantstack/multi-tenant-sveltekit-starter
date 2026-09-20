[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: exportAuditJson()

> **exportAuditJson**(`db`, `orgId`, `limit`, `offset`): `Promise`\<`Record`\<`string`, `unknown`\>[]\>

Export an organization's audit log as JSON.

## Parameters

### db

[`Db`](../../type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

### limit

`number` = `1000`

Maximum rows to export (default `1000`).

### offset

`number` = `0`

Row offset (default `0`).

## Returns

`Promise`\<`Record`\<`string`, `unknown`\>[]\>

A JSON array of audit entries with parsed metadata.
