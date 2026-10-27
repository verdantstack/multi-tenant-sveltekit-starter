[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: requirePermission()

> **requirePermission**(`role`, `permission`): `void`

Assert that `role` holds `permission`, otherwise throw an authorization error.

## Parameters

### role

The caller's role; `null`/`undefined` is treated as having no capabilities.

`"owner"` | `"admin"` | `"member"` | `null` | `undefined`

### permission

The required permission.

`"org.view"` | `"members.view"` | `"members.invite"` | `"members.remove"` | `"members.role.set"` | `"invites.revoke"` | `"audit.view"` | `"billing.manage"` | `"ownership.transfer"`

## Returns

`void`

## Throws

with code `forbidden` when the role lacks the permission
(including when no role is provided).
