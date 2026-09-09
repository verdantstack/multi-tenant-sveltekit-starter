[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Type Alias: Db

> **Db** = `BetterSQLite3Database`\<*typeof* [`db/schema`](../schema/README.md)\>

A Drizzle handle over the SQLite connection, typed against the full schema.
Pass it into services — they never open their own connection.
