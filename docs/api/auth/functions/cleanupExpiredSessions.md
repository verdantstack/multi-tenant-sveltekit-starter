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

## Remarks

The predicate is "strictly in the past" (`lt`), which is what
`getUserBySessionToken` treats as expired — a session expiring at exactly the
current millisecond is already unusable. It previously used `eq`, matching only
sessions whose expiry was *exactly* `Date.now()`, which no session is ever
created to be: the sweep deleted nothing and the table grew without bound.
