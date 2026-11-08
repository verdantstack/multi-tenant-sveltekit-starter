[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: RetentionPolicy

Retention policy describing how long audit rows are kept.

## Properties

### maxAgeMs

> **maxAgeMs**: `number`

Maximum age of an audit row in milliseconds; older rows are pruned.

***

### maxRows?

> `optional` **maxRows**: `number`

Optional cap on the number of rows retained.
