[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Type Alias: AuditEntry

> **AuditEntry** = `object`

Data for a single audit event. `orgId` and `actorUserId` are optional so system-level or
pre-org actions can still be logged; `metadata` is arbitrary JSON-serializable data about
the action.

## Properties

### action

> **action**: `string`

***

### actorUserId?

> `optional` **actorUserId**: `string` \| `null`

***

### metadata?

> `optional` **metadata**: `Record`\<`string`, `unknown`\>

***

### orgId?

> `optional` **orgId**: `string` \| `null`

***

### targetId?

> `optional` **targetId**: `string` \| `null`

***

### targetType?

> `optional` **targetType**: `string` \| `null`
