[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Variable: organizations

> `const` **organizations**: `SQLiteTableWithColumns`\<\{ `columns`: \{ `createdAtMs`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteInteger"`; `data`: `number`; `dataType`: `"number"`; `driverParam`: `number`; `enumValues`: `undefined`; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"created_at_ms"`; `notNull`: `true`; `tableName`: `"organizations"`; \}, \{ \}, \{ \}\>; `dpaAcceptedAtMs`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteInteger"`; `data`: `number`; `dataType`: `"number"`; `driverParam`: `number`; `enumValues`: `undefined`; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"dpa_accepted_at_ms"`; `notNull`: `false`; `tableName`: `"organizations"`; \}, \{ \}, \{ \}\>; `id`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `true`; `name`: `"id"`; `notNull`: `true`; `tableName`: `"organizations"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; `name`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"name"`; `notNull`: `true`; `tableName`: `"organizations"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; `regionCode`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `true`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"region_code"`; `notNull`: `true`; `tableName`: `"organizations"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; `slug`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"slug"`; `notNull`: `true`; `tableName`: `"organizations"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; \}; `dialect`: `"sqlite"`; `name`: `"organizations"`; `schema`: `undefined`; \}\>

Top-level tenant. `slug` is unique and used in profile URLs for routing within the product.

`regionCode` is the tenant's data-residency home — the jurisdiction its rows
are processed in and the policy those rows are subject to. It is written once
at creation (`services/orgs.ts:createOrg`) and thereafter only by
`services/residency.ts:completeRegionChange`, which is the single `UPDATE` to
this column in the codebase. Nothing else may change it: a silent re-homing is
the failure this column exists to make impossible.

`dpaAcceptedAtMs` records when the tenant accepted the region's data-processing
agreement, or `null` when that region requires none. It is not a boolean
because a compliance reviewer asks *when*, and "yes" cannot be reconciled
against the version of the agreement that was live at the time.
