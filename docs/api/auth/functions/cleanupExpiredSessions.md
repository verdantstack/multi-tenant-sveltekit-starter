[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: cleanupExpiredSessions()

> **cleanupExpiredSessions**(`db`): `Promise`\<`number`\>

Remove expired sessions from the database.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

## Returns

`Promise`\<`number`\>

The number of expired sessions removed.
