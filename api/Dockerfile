FROM node:18-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000
CMD ["node", "index.js"]
LABEL org.opencontainers.image.source="https://github.com/woorzz/forum-anonyme"