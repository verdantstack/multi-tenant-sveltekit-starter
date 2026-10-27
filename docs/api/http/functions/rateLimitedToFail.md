[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: rateLimitedToFail()

> **rateLimitedToFail**(`retryAfterMs`): `ActionFailure`\<\{ `error`: `string`; \}\>

The one HTTP representation of a rate-limit verdict.

It lives here, beside [errorToFail](errorToFail.md), because every action that consults a
`RateLimiter` needs to answer the same way. The wording was previously written
out in the `/login` action only, which meant a second auth surface added later
(the invite-accept actions) had no rate limiting *and* no shared 429 to reuse —
so the gap was invisible. Anything that gates on `RateLimiter.check` should
return this.

The message is deliberately vague about how many attempts remain: telling a
caller "4 of 5 used" is free guidance for tuning an attack.

## Parameters

### retryAfterMs

`number`

Milliseconds until the window frees up.

## Returns

`ActionFailure`\<\{ `error`: `string`; \}\>

A 429 `ActionFailure`.
