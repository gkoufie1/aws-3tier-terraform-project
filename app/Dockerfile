FROM node:20-alpine

# Upgrade all system packages to pick up security patches, then add curl for health checks
RUN apk upgrade --no-cache && apk add --no-cache curl

WORKDIR /app

# Copy manifests first so dependency layer is cached independently of source changes
COPY --chown=node:node package*.json ./
RUN npm ci --only=production

COPY --chown=node:node . .

ENV NODE_ENV=production

EXPOSE 3000

USER node

CMD ["node", "server.js"]
