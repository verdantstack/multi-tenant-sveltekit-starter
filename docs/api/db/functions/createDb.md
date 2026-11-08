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

## Remarks

**Single-writer assumption — read before running more than one
instance against one database file.** The boot-time `migrate()` call is a
safety net, not a deployment strategy. It is safe when a single process
writes to the database: local dev, a single container, a preview deploy.
It is NOT safe when several instances start concurrently against the same
database file — a shared network volume, a multi-replica deploy, or any
host where the file is not local to the process. Each instance
independently decides which migrations are pending, so they can race and
produce `column already exists` or a partially applied migration.

In those shapes run `npm run db:migrate` as the only writer — once, before
the new version starts serving traffic — and let this call find nothing left
to do.

The D1 port in `the Cloudflare D1 demo` faces the same race against a remote database
for the same reason; the mitigation is identical.
