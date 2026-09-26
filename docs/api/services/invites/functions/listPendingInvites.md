[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: listPendingInvites()

> **listPendingInvites**(`db`, `orgId`): `Promise`\<`object`[]\>

List the still-pending, un-expired invites for an organization.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<`object`[]\>

Invites that are neither accepted, revoked, nor expired, newest first.
