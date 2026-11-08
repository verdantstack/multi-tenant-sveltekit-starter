[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: CreateOrgOptions

Options accepted by [createOrg](../functions/createOrg.md) for choosing the tenant's region.

## Properties

### dpaAccepted?

> `optional` **dpaAccepted**: `boolean`

Whether the creator accepted the region's data-processing agreement in this
request. Required by, and only meaningful for, a region whose policy sets
`requiresDpaAcceptance`.

***

### regionCode?

> `optional` **regionCode**: `string` \| `null`

Region code to home the organization in. Omitted means
`regions.defaultRegionCode()` — `REGION_DEFAULT`, or `us-east-1`.
