[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: AuditExport

The result of an export that passed the region policy.

## Properties

### body

> **body**: `string`

The rendered document.

***

### contentType

> **contentType**: `string`

`'text/csv; charset=utf-8'` or `'application/json; charset=utf-8'`.

***

### destinationRegion

> **destinationRegion**: `string`

Where the export was addressed.

***

### pseudonymized

> **pseudonymized**: `boolean`

Whether identifiers were replaced on the way out.

***

### region

> **region**: `string`

The tenant's own region.

***

### rowCount

> **rowCount**: `number`

How many events the document contains.
