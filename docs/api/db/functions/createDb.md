[**multi-tenant-sveltekit-starter**](../../README.md)

***

# Function: createDb()

> **createDb**(`file`): [`Db`](../type-aliases/Db.md)

Open (or create) a database and apply the checked-in migrations.

## Parameters

### file

`string`

Either `:memory:` for an isolated in-process database (used by tests) or a
  filesystem path, whose parent directory is created if missing. Foreign keys are enabled
  and, for file-backed databases, WAL journaling is turned on.

## Returns

[`Db`](../type-aliases/Db.md)

The migrated database handle.
