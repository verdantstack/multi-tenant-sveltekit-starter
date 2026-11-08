[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: deleteOwnAccount()

> **deleteOwnAccount**(`db`, `input`): `Promise`\<\{ `deletedOrgIds`: `string`[]; `userId`: `string`; \}\>

Close the signed-in user's account.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

#### sessionToken

`string` \| `undefined`

The raw session token from the cookie.

## Returns

`Promise`\<\{ `deletedOrgIds`: `string`[]; `userId`: `string`; \}\>

The closed user id and the organizations deleted with it.

## Remarks

Order matters and is pinned by a test: the audit rows are inserted
first, in the same transaction, because after the `DELETE` there is no user id
left to attribute them to — and `audit_log` has no foreign key, so those rows
survive the account they describe.

## Throws

`unauthenticated` when the token resolves to no user, or
`last_owner` when an organization would be left with no owner.
