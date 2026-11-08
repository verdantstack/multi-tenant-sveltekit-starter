[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: auditRow()

> **auditRow**(`entry`): `object`

The row an [AuditEntry](../type-aliases/AuditEntry.md) becomes.

Split out so a caller writing inside a database transaction can produce an
identical row without awaiting `audit()`. Under better-sqlite3 every statement
executes synchronously, but `await` still yields to a microtask — so awaiting
inside a transaction callback would let the driver COMMIT before the rest of
the writes ran, silently splitting one logical operation into two. A
transaction therefore uses this builder and `.run()`s the result itself.

## Parameters

### entry

[`AuditEntry`](../type-aliases/AuditEntry.md)

The event to record.

## Returns

`object`

The values to insert into `audit_log`.

### action

> **action**: `string` = `entry.action`

### actorUserId

> **actorUserId**: `string` \| `null`

### createdAtMs

> **createdAtMs**: `number`

### metadataJson

> **metadataJson**: `string` \| `null`

### orgId

> **orgId**: `string` \| `null`

### targetId

> **targetId**: `string` \| `null`

### targetType

> **targetType**: `string` \| `null`
