[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: recordAuditExport()

> **recordAuditExport**(`db`, `orgId`, `actorUserId`, `exportResult`): `Promise`\<`void`\>

Write the audit row for an export that went out through
[exportOrgAudit](exportOrgAudit.md).

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

### actorUserId

`string`

The user who triggered the export.

### exportResult

[`AuditExport`](../interfaces/AuditExport.md)

What [exportOrgAudit](exportOrgAudit.md) returned.

## Returns

`Promise`\<`void`\>

## Remarks

Kept separate from the export itself so the rendering path stays a
read: the route decides when a delivery actually happened `and` records it.
The destination region is recorded with it — an export log that says only
"someone exported" cannot answer the question a residency review asks.
