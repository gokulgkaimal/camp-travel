# --- Frontend Dockerfile ---
# Stage 1: build react app
FROM node:22 AS build

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: serve static files with nginx
FROM nginx:alpine

# copy build output to nginx html folder
COPY --from=build /app/dist /usr/share/nginx/html

# copy a default nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
