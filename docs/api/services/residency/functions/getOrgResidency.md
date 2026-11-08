[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: getOrgResidency()

> **getOrgResidency**(`db`, `orgId`): `Promise`\<[`OrgResidency`](../interfaces/OrgResidency.md)\>

Read a tenant's region and the policy it implies.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### orgId

`string`

The organization id.

## Returns

`Promise`\<[`OrgResidency`](../interfaces/OrgResidency.md)\>

The organization's residency, including any open change request.

## Throws

`not_found` when the organization does not exist, or
`unknown_region` when its stored code is not in this deployment's catalogue
(a deploy that removed a region still holding tenants, which must be loud).
