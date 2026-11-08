[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Function: accountDeletionImpact()

> **accountDeletionImpact**(`db`, `userId`): `Promise`\<[`AccountDeletionImpact`](../interfaces/AccountDeletionImpact.md)\>

Work out what deleting an account would affect.

## Parameters

### db

[`Db`](../../../db/type-aliases/Db.md)

The database handle.

### userId

`string`

The user whose account is being closed.

## Returns

`Promise`\<[`AccountDeletionImpact`](../interfaces/AccountDeletionImpact.md)\>

The organizations that block the deletion and the ones that would be
deleted with it.

## Remarks

Separated from [deleteOwnAccount](deleteOwnAccount.md) so a confirmation screen can
show the consequences before they happen, and so the decision is testable on
its own. Three queries regardless of how many organizations the user is in —
the per-organization loop this replaced was an N+1 that a user with a dozen
organizations would have felt.
