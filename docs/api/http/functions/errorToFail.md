[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: errorToFail()

> **errorToFail**(`e`): `ActionFailure`\<\{ `error`: `string`; \}\>

Single place where domain errors become HTTP responses.
RBAC failures are 403; everything else the user can act on is 400.

SvelteKit's `redirect()` signals success by throwing a control-flow object
(it carries `location`, not `code`). Swallowing it here would turn any
successful action that redirects inside a try/catch into a 500 after its
side effects already committed — so redirects always propagate.

## Parameters

### e

`unknown`

An unknown thrown value, typically a typed error class carrying `code`/`message`.

## Returns

`ActionFailure`\<\{ `error`: `string`; \}\>

An `ActionFailure` whose status derives from the error's `code`: `forbidden`,
  `hierarchy_violation`, and `no_membership` map to 403, `not_found` to 404, known error
  classes to 400, and anything unmapped or unexpected results in a 500 with a generic
  message.

## Throws

The original value when it is a SvelteKit redirect control-flow object, so
  successful redirects propagate rather than being converted to a failure.
