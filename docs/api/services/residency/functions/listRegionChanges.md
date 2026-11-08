[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: listRegionChanges()

> **listRegionChanges**(`db`, `orgId`): `Promise`\<[`RegionMoveView`](../interfaces/RegionMoveView.md)[]\>

Every region change recorded for a tenant, newest first.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<[`RegionMoveView`](../interfaces/RegionMoveView.md)[]\>

The move history; empty when the tenant has never asked to move.
