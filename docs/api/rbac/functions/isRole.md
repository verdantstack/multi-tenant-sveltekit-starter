[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: isRole()

> **isRole**(`value`): value is "owner" \| "admin" \| "member"

Narrow a raw string to a `Role`, or return `false` when it is not one.

## Parameters

### value

`string`

The role string to test.

## Returns

value is "owner" \| "admin" \| "member"

`true` and narrows `value` to `Role` when it is a known role.
