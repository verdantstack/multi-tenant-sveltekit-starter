[**multi-tenant-sveltekit-starter**](../../../README.md)

***

# Interface: McpTool

A tool as MCP describes it: a name, a description, and a JSON Schema.

## Properties

### description

> **description**: `string`

***

### handler()

> **handler**: (`db`, `args`) => `Promise`\<`unknown`\>

#### Parameters

##### db

[`Db`](../../../db/type-aliases/Db.md)

##### args

`Record`\<`string`, `unknown`\>

#### Returns

`Promise`\<`unknown`\>

***

### inputSchema

> **inputSchema**: `Record`\<`string`, `unknown`\>

***

### name

> **name**: `string`
