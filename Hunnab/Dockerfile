# ---- Build stage: instala dependencias ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- Runtime stage ----
FROM node:20-alpine AS runtime
WORKDIR /app

# Copia solo lo necesario (sin node_modules de dev, sin src de React)
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY server/ ./server/

# Puerto que expone la API
EXPOSE 4000

# Variables de entorno por defecto (se sobreescriben con --env-file o docker-compose)
ENV NODE_ENV=production \
    API_PORT=4000

CMD ["node", "server/index.mjs"]
