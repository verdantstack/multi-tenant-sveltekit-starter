[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: hashPassword()

> **hashPassword**(`password`): `Promise`\<`string`\>

Derive a self-describing scrypt hash from a plaintext password.

## Parameters

### password

`string`

The plaintext password to hash.

## Returns

`Promise`\<`string`\>

A `scrypt$N$r$p$salt$hash` encoded string.

## Remarks

Uses the OWASP-listed scrypt parameters for interactive logins (see
`SCRYPT`). The returned string encodes the scheme, parameters, salt, and
hash, so it can be verified later without knowing the original parameters —
which is what lets the work factor be raised without invalidating existing
hashes.
