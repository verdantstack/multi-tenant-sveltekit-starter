[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Variable: rateLimitEntries

> `const` **rateLimitEntries**: `SQLiteTableWithColumns`\<\{ `columns`: \{ `id`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `true`; `name`: `"id"`; `notNull`: `true`; `tableName`: `"rate_limit_entries"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; `key`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteText"`; `data`: `string`; `dataType`: `"string"`; `driverParam`: `string`; `enumValues`: \[`string`, `...string[]`\]; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"key"`; `notNull`: `true`; `tableName`: `"rate_limit_entries"`; \}, \{ \}, \{ `length`: `number` \| `undefined`; \}\>; `timestampMs`: `SQLiteColumn`\<\{ `baseColumn`: `never`; `columnType`: `"SQLiteInteger"`; `data`: `number`; `dataType`: `"number"`; `driverParam`: `number`; `enumValues`: `undefined`; `generated`: `undefined`; `hasDefault`: `false`; `hasRuntimeDefault`: `false`; `identity`: `undefined`; `isAutoincrement`: `false`; `isPrimaryKey`: `false`; `name`: `"timestamp_ms"`; `notNull`: `true`; `tableName`: `"rate_limit_entries"`; \}, \{ \}, \{ \}\>; \}; `dialect`: `"sqlite"`; `name`: `"rate_limit_entries"`; `schema`: `undefined`; \}\>

Rate limit entries for shared-store rate limiting.
