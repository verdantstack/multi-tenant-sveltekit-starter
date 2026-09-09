[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: getDb()

> **getDb**(): [`Db`](../type-aliases/Db.md)

Return the process-wide shared database, creating and opening it on first call.

## Returns

[`Db`](../type-aliases/Db.md)

The shared database handle.

## Remarks

The database location is controlled by `DATA_DIR` (default `./data`); it lives at
  `<DATA_DIR>/app.db`. The singleton is memoized — later calls return the same handle.
