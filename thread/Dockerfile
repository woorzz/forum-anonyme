FROM node:18-alpine AS builder
WORKDIR /app

# Argument pour l'URL de l'API
ARG API_URL=http://localhost:3000

COPY package*.json nuxt.config.ts ./
RUN npm ci
COPY . .

# Remplacer l'URL de l'API dans le code avant le build
RUN sed -i "s|http://localhost:3000|${API_URL}|g" pages/thread.vue

RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/.output ./.output
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
LABEL org.opencontainers.image.source="https://github.com/woorzz/forum-anonyme"