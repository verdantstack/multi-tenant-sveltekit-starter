[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: mayActOn()

> **mayActOn**(`actor`, `target`): `boolean`

Returns whether an actor may act upon a target based on rank.

## Parameters

### actor

The acting role.

`"owner"` | `"admin"` | `"member"`

### target

The role being acted upon.

`"owner"` | `"admin"` | `"member"`

## Returns

`boolean`

`true` when `actor` outranks `target`.

## Remarks

Hierarchy rule: an actor may only act on targets strictly below its
own rank, i.e. `rank(actor) > rank(target)`. An `admin` can therefore never
act on another `admin` or an `owner`.
