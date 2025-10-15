FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json nuxt.config.ts ./
RUN npm ci
COPY . .

RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/.output ./.output

# Script pour injecter les URLs au démarrage
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'cat > /app/.output/public/config.js << EOF' >> /entrypoint.sh && \
    echo 'window.RUNTIME_CONFIG = { API_URL: "${API_URL}", SENDER_URL: "${SENDER_URL}", THREAD_URL: "${THREAD_URL}" };' >> /entrypoint.sh && \
    echo 'EOF' >> /entrypoint.sh && \
    echo 'exec node .output/server/index.mjs' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 3000
CMD ["/entrypoint.sh"]
LABEL org.opencontainers.image.source="https://github.com/woorzz/forum-anonyme"