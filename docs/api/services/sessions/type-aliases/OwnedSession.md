[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Type Alias: OwnedSession

> **OwnedSession** = `object`

One of the caller's own sessions, as shown in the UI.

## Properties

### createdAtMs

> **createdAtMs**: `number`

When the session was issued, as a Unix epoch timestamp in milliseconds.

***

### current

> **current**: `boolean`

`true` for the session making this request, which revocation will not touch.

***

### expiresAtMs

> **expiresAtMs**: `number`

When the session expires, as a Unix epoch timestamp in milliseconds.

***

### id

> **id**: `string`

The session id — `sha256(token)`. The raw token is never recoverable from it.
