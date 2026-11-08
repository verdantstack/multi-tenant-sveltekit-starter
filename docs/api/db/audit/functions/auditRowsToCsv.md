[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: auditRowsToCsv()

> **auditRowsToCsv**(`rows`): `string`

Render audit rows as CSV.

## Parameters

### rows

readonly [`AuditRow`](../type-aliases/AuditRow.md)[]

The rows to render, already in output order.

## Returns

`string`

A CSV document with a header row.

## Remarks

Split out of [exportAuditCsv](exportAuditCsv.md) so a caller that must transform
the rows first — `services/residency.ts` pseudonymises `actorUserId` under a
region policy — formats them through the *same* escape and formula-guard code
instead of re-deriving it. Two CSV writers is how one of them quietly loses
the injection guard.
