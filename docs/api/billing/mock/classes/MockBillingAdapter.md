[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Class: MockBillingAdapter

Deterministic local implementation used in development, tests, and until a
merchant-of-record account is approved/wired. Behavior:
 - every org is considered on an `active` plan…
 - …with MOCK_PLAN_SEATS seats (env var, default 3).
Checkout URL creation returns null (nothing external to link to).

## Implements

- [`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md)

## Constructors

### Constructor

> **new MockBillingAdapter**(`opts`): `MockBillingAdapter`

Create a mock adapter.

#### Parameters

##### opts

Configuration options.

###### planSeats?

`number`

Seat count to report; defaults to the
`MOCK_PLAN_SEATS` environment variable, then 3.

#### Returns

`MockBillingAdapter`

## Properties

### name

> `readonly` **name**: `"mock"` = `'mock'`

Adapter identifier, `mock`.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`name`](../../adapter/interfaces/BillingAdapter.md#name)

## Methods

### createCheckoutUrl()

> **createCheckoutUrl**(`_input`): `Promise`\<`string` \| `null`\>

Mock checkout is never configured.

#### Parameters

##### \_input

Ignored.

###### orgId

`string`

###### seats

`number`

#### Returns

`Promise`\<`string` \| `null`\>

`null`, signalling no external checkout URL exists.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`createCheckoutUrl`](../../adapter/interfaces/BillingAdapter.md#createcheckouturl)

***

### getSubscriptionState()

> **getSubscriptionState**(`_orgId`): `Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

Report a static `active` subscription for any organization.

#### Parameters

##### \_orgId

`string`

Ignored; every org is on the same mock plan.

#### Returns

`Promise`\<[`SubscriptionState`](../../adapter/type-aliases/SubscriptionState.md)\>

An `active` state with the configured seat count.

#### Implementation of

[`BillingAdapter`](../../adapter/interfaces/BillingAdapter.md).[`getSubscriptionState`](../../adapter/interfaces/BillingAdapter.md#getsubscriptionstate)
