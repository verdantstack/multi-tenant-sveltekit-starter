[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: audit()

> **audit**(`db`, `entry`): `Promise`\<`void`\>

Append-only audit writer. There is deliberately no update/delete API —
compliance buyers ask for exactly this property.

## Parameters

### db

[`Db`](../../type-aliases/Db.md)

The database handle to write into.

### entry

[`AuditEntry`](../type-aliases/AuditEntry.md)

The event to record; `metadata` is serialized to JSON and stored as text.

## Returns

`Promise`\<`void`\>

A promise that resolves once the event is persisted.
