[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: cancelRegionChange()

> **cancelRegionChange**(`db`, `input`): `Promise`\<`void`\>

Cancel an open region change. The tenant stays where it is.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### input

#### actorRole

`"owner"` \| `"admin"` \| `"member"` \| `null` \| `undefined`

Re-derived role in this organization.

#### actorUserId

`string`

The acting user id.

#### moveId

`string`

The open request to cancel.

#### now?

`number`

Injectable clock for tests; defaults to `Date.now()`.

#### orgId

`string`

The organization id.

## Returns

`Promise`\<`void`\>

## Throws

`forbidden` when the actor lacks `org.region.move`.

## Throws

`no_pending_move` when the id is not an open request.
