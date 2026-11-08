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

`true` when the password matches; `false` for a mismatch, an
unsupported hashing scheme, or a stored value too malformed to derive from.

## Remarks

Comparison uses `timingSafeEqual` to avoid leaking information. The
work factor is read from the stored value, not from `SCRYPT`, so hashes
written before the work factor was raised still verify.
