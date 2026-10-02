[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: handleMessage()

> **handleMessage**(`db`, `raw`): `Promise`\<`unknown`\>

Handle one JSON-RPC message and return the reply, or null for a notification.
Exported so the tests can drive the protocol without spawning a process.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

### raw

`string`

## Returns

`Promise`\<`unknown`\>
