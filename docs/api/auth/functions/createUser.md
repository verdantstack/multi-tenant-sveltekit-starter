[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: createUser()

> **createUser**(`db`, `input`): `Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

Create a new user account with hashed credentials.

## Parameters

### db

[`Db`](../../db/type-aliases/Db.md)

The database handle.

### input

The raw sign-up payload.

#### email

`string`

The user's email address.

#### name

`string`

The user's display name; falls back to the email local-part when empty.

#### password

`string`

The user's password, checked against `MIN_PASSWORD_LENGTH`.

## Returns

`Promise`\<\{ `email`: `string`; `id`: `string`; `name`: `string`; \}\>

The created user's id, normalized email, and name.

## Throws

with code `invalid_email`, `weak_password`, or `email_taken`
when validation fails or the email is already registered.
