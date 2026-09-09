[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: destroyAllSessions()

> **destroyAllSessions**(`db`, `userId`, `exceptToken?`): `Promise`\<`void`\>

Revoke all sessions for a user except the current one (optional).
Useful for "log out everywhere" security feature.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user whose sessions to destroy.

### exceptToken?

`string`

Optional current session token to preserve.

## Returns

`Promise`\<`void`\>
