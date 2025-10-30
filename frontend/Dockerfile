# --- build stage ---
FROM node:22 AS build
WORKDIR /app
COPY package.json package-lock.json* ./
# If lock not present, fallback to npm install
RUN npm ci || npm install
COPY . .
RUN npm run build

# --- serve stage ---
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

