[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: verifyPassword()

> **verifyPassword**(`password`, `stored`): `Promise`\<`boolean`\>

Verify a plaintext password against an encoded scrypt hash.

## Parameters

### password

`string`

The plaintext password to check.

### stored

`string`

The `scrypt$…` string produced by `hashPassword()`.

## Returns

`Promise`\<`boolean`\>

`true` when the password matches; `false` for a mismatch or an
unsupported hashing scheme.

## Remarks

Comparison uses `timingSafeEqual` to avoid leaking information.
