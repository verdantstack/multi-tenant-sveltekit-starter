[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: mayGrant()

> **mayGrant**(`actor`, `granted`): `boolean`

Returns whether an actor may grant a role to someone else.

## Parameters

### actor

The role granting the new role.

`"owner"` | `"admin"` | `"member"`

### granted

The role being granted.

`"owner"` | `"admin"` | `"member"`

## Returns

`boolean`

`true` when `granted` is strictly below `actor`.

## Remarks

Hierarchy rule: the granted role must be strictly below the actor's
own rank, i.e. `rank(actor) > rank(granted)`. No self- or equal-rank grants.
