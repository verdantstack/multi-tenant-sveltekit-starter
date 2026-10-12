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

Maximum rows to export (default `1000`, capped at [MAX\_EXPORT\_ROWS](../variables/MAX_EXPORT_ROWS.md)).

### offset

`number` = `0`

Row offset (default `0`).

## Returns

`Promise`\<`Record`\<`string`, `unknown`\>[]\>

A JSON array of audit entries with parsed metadata.

## Remarks

A row whose `metadataJson` will not parse is reported as the raw
string rather than aborting the export. The log is append-only with no UPDATE
path, so a corrupt row can never be repaired — throwing here would deny the
buyer every other event in the file, including the ones they actually need.
