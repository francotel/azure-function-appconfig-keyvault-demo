# -------- Stage 1: Build --------
FROM node:18-alpine AS build
WORKDIR /usr/src/app

# Copiamos archivos necesarios
COPY package*.json ./
RUN npm install --omit=dev

# Copiamos el resto del código
COPY . .

# -------- Stage 2: Runtime --------
FROM node:18-alpine
WORKDIR /usr/src/app

# Copiamos dependencias ya instaladas
COPY --from=build /usr/src/app /usr/src/app

# Exponemos el puerto del microservicio
EXPOSE 4000

# Variables de entorno (puedes sobreescribirlas con `docker run -e`)
ENV PORT=4000

# Comando de inicio
CMD ["node", "server.js"]