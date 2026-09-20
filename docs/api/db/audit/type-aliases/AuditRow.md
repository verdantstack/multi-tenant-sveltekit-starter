[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Type Alias: AuditRow

> **AuditRow** = `object`

A stored audit row as returned by [listAudit](../functions/listAudit.md). `metadataJson` is the raw stored JSON
string; `createdAtMs` is a Unix epoch timestamp in milliseconds.

## Properties

### action

> **action**: `string`

***

### actorUserId

> **actorUserId**: `string` \| `null`

***

### createdAtMs

> **createdAtMs**: `number`

***

### metadataJson

> **metadataJson**: `string` \| `null`

***

### seq

> **seq**: `number`

***

### targetId

> **targetId**: `string` \| `null`

***

### targetType

> **targetType**: `string` \| `null`
