FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json nuxt.config.ts ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/.output ./.output
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
LABEL org.opencontainers.image.source="https://github.com/woorzz/forum-anonyme"