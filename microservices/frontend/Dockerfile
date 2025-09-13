# Stage 1: Build React app
FROM node:18 as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of frontend code
COPY . .

# Build optimized production version
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy build files to nginx html folder
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
