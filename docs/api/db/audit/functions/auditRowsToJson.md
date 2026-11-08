[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: auditRowsToJson()

> **auditRowsToJson**(`rows`): `Record`\<`string`, `unknown`\>[]

Render audit rows as plain JSON objects, with `metadata` parsed.

## Parameters

### rows

readonly [`AuditRow`](../type-aliases/AuditRow.md)[]

The rows to render, already in output order.

## Returns

`Record`\<`string`, `unknown`\>[]

One object per row, safe to `JSON.stringify`.

## Remarks

The JSON twin of [auditRowsToCsv](auditRowsToCsv.md), split out for the same
reason: a residency policy that pseudonymises actors transforms rows and then
calls this, so the `metadata` fallback (a corrupt row is exported as its raw
text rather than aborting the file) is defined in exactly one place.
