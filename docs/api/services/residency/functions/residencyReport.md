[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: residencyReport()

> **residencyReport**(`db`, `orgId`, `options`): `Promise`\<[`ResidencyReport`](../interfaces/ResidencyReport.md)\>

Build the tenant's residency report.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

### options

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

## Returns

`Promise`\<[`ResidencyReport`](../interfaces/ResidencyReport.md)\>

The residency posture, data-class counts and retention posture.

## Remarks

Read-only, and deliberately so: the two retention numbers are
*reported* rather than enforced, because the audit log is append-only by
design and this kit has no business deleting a compliance trail on a timer.
The operator's pruning job reads these figures and decides.

## Throws

`not_found`/`unknown_region` as [getOrgResidency](getOrgResidency.md) does.
