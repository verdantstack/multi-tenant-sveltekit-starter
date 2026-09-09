[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: can()

> **can**(`role`, `permission`): `boolean`

Returns whether `role` is granted `permission` by the static capability matrix.

## Parameters

### role

The role being evaluated. `owner` has every permission; `admin` and
`member` are limited to the subsets declared in this module.

`"owner"` | `"admin"` | `"member"`

### permission

The permission to test for.

`"org.view"` | `"members.view"` | `"members.invite"` | `"members.remove"` | `"members.role.set"` | `"invites.revoke"` | `"audit.view"` | `"billing.manage"` | `"ownership.transfer"`

## Returns

`boolean`

`true` when the role may exercise the permission.
