[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: listSessions()

> **listSessions**(`db`, `userId`): `Promise`\<`object`[]\>

List all active sessions for a user.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user id.

## Returns

`Promise`\<`object`[]\>

An array of session metadata for all sessions, newest first.
