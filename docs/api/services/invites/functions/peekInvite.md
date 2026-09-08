[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: peekInvite()

> **peekInvite**(`db`, `token`): `Promise`\<\{ `state`: `"invalid"`; \} \| \{ `state`: `"expired"`; \} \| \{ `state`: `"revoked"`; \} \| \{ `state`: `"accepted"`; \} \| \{ `expiresAtMs`: `number`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; `state`: `"valid"`; \}\>

Read-only preview for the landing page of an invite link — never mutates.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### token

`string`

The raw invite token.

## Returns

`Promise`\<\{ `state`: `"invalid"`; \} \| \{ `state`: `"expired"`; \} \| \{ `state`: `"revoked"`; \} \| \{ `state`: `"accepted"`; \} \| \{ `expiresAtMs`: `number`; `orgName`: `string`; `role`: `"owner"` \| `"admin"` \| `"member"`; `state`: `"valid"`; \}\>

A discriminated union describing the invite's state: `invalid`,
`expired`, `revoked`, `accepted`, or `valid` (with org name, role, and expiry).
