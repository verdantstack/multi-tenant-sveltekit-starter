import type { Config } from 'drizzle-kit';

export default {
	schema: './src/lib/server/db/schema.ts',
	out: './drizzle',
	dialect: 'sqlite',
	dbCredentials: {
		// drizzle-kit only reads this for push/studio; migrations are applied at runtime.
		url: process.env.DATA_DIR ? `${process.env.DATA_DIR}/app.db` : './data/app.db'
	}
} satisfies Config;
