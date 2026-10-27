[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Class: StripeBillingAdapter

Billing adapter backed by Stripe Checkout.

## Implements

- [`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

## Constructors

### Constructor

> **new StripeBillingAdapter**(`secretKey?`, `priceId?`): `StripeBillingAdapter`

Create a Stripe adapter.

#### Parameters

##### secretKey?

`string`

Stripe secret key (falls back to `STRIPE_SECRET_KEY`).

##### priceId?

`string`

Stripe price id (falls back to `STRIPE_PRICE_ID`).

#### Returns

`StripeBillingAdapter`

## Properties

### name

> `readonly` **name**: `"stripe"` = `'stripe'`

A stable identifier for the adapter (e.g. `mock`).

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`name`](../../adapter/interfaces/BillingAdapter.md#name)

## Accessors

### isConfigured

#### Get Signature

> **get** **isConfigured**(): `boolean`

Whether the adapter is configured with both key and price.

##### Returns

`boolean`

## Methods

### createCheckoutUrl()

> **createCheckoutUrl**(`input`): `Promise`\<`string` \| `null`\>

Create a Stripe Checkout URL.

#### Parameters

##### input

Checkout parameters.

###### orgId

`string`

Organization id.

###### seats

`number`

Seat count.

#### Returns

`Promise`\<`string` \| `null`\>

Checkout URL, or `null` when unconfigured.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`createCheckoutUrl`](../../adapter/interfaces/BillingAdapter.md#createcheckouturl)

***

### getSubscriptionState()

> **getSubscriptionState**(`_orgId`): `Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Get subscription state for an organization.

#### Parameters

##### \_orgId

`string`

Organization id (unused in stub).

#### Returns

`Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Subscription state (stub returns `none`).

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSubscriptionState`](../../adapter/interfaces/BillingAdapter.md#getsubscriptionstate)
