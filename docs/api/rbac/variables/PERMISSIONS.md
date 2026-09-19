[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Variable: PERMISSIONS

> `const` **PERMISSIONS**: readonly \[`"org.view"`, `"members.view"`, `"members.invite"`, `"members.remove"`, `"members.role.set"`, `"invites.revoke"`, `"audit.view"`, `"billing.manage"`, `"ownership.transfer"`\]

The full set of granular permissions recognized by the kit.

## Remarks

The static capability matrix in this module maps each role to the
subset of these permissions it may exercise.
