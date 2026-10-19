# Multi-tenant SvelteKit Starter — Docker image
#
#   docker build -t multi-tenant-starter .
#   docker run -p 5173:5173 -v multi-tenant-data:/app/data multi-tenant-starter
#
# The SQLite database lives in /app/data/app.db (persisted via volume).

FROM node:24-alpine AS builder

WORKDIR /app

# Install dependencies first (layer caching)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# --- Production stage ---
FROM node:24-alpine

WORKDIR /app

# Copy built app + production dependencies
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/build ./build
COPY --from=builder /app/drizzle ./drizzle
COPY --from=builder /app/node_modules/better-sqlite3 ./node_modules/better-sqlite3

# SQLite data directory
RUN mkdir -p /app/data

ENV NODE_ENV=production
ENV DATA_DIR=/app/data
ENV PORT=5173

EXPOSE 5173

CMD ["node", "build"]
