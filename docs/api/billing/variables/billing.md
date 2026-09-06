[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Variable: billing

> `const` **billing**: [`BillingAdapter`](../adapter/interfaces/BillingAdapter.md)

Single wiring point. When a merchant-of-record account is approved and
verified (see docs/billing.md), replace with e.g.:
  export const billing: BillingAdapter = new LemonSqueezyBillingAdapter(env);
No other file needs to change.

## Remarks

The exported adapter is the only billing instance services and routes
should consume; never construct an adapter elsewhere.
