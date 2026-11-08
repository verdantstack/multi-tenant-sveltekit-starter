[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: AccountDeletionImpact

What closing an account would do, computed without writing anything.

## Properties

### blocking

> **blocking**: `object`[]

Organizations with other members that this user solely owns — these block deletion.

#### id

> **id**: `string`

#### name

> **name**: `string`

***

### cascading

> **cascading**: `object`[]

Organizations where this user is the only member — these are deleted with the account.

#### id

> **id**: `string`

#### name

> **name**: `string`
