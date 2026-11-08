[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Variable: MAX\_EXPORT\_ROWS

> `const` **MAX\_EXPORT\_ROWS**: `10000` = `10_000`

Upper bound on rows a single export call may return.

## Remarks

An audit export is reachable through a request parameter, so `limit`
is clamped rather than trusted. Without a ceiling one request can ask for the
entire append-only log and exhaust the process's memory on exactly the table
designed to grow forever. 10 000 rows is roughly what a compliance export page
needs; larger exports are paged with `offset`.
