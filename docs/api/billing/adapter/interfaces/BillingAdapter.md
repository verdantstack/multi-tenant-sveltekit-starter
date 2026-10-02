[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: BillingAdapter

The seam between the product and a merchant-of-record subscription provider.

## Remarks

Implementations are interchangeable; the product never imports a
specific provider SDK directly. See the adapter implementations for behavior.

## Properties

### name

> `readonly` **name**: `string`

A stable identifier for the adapter (e.g. `mock`).

## Methods

### createCheckoutUrl()

> **createCheckoutUrl**(`input`): `Promise`\<`string` \| `null`\>

Returns a hosted-checkout URL, or null when checkout isn't configured.

#### Parameters

##### input

###### orgId

`string`

###### seats

`number`

#### Returns

`Promise`\<`string` \| `null`\>

***

### getSubscriptionState()

> **getSubscriptionState**(`orgId`): `Promise`\<[`SubscriptionState`](../type-aliases/SubscriptionState.md)\>

Fetch the current subscription state for an organization.

#### Parameters

##### orgId

`string`

The organization id.

#### Returns

`Promise`\<[`SubscriptionState`](../type-aliases/SubscriptionState.md)\>

The current subscription state, including the paid seat count.
