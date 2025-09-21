# Use Node.js LTS image
# FROM node:18
# WORKDIR /app
# COPY package*.json ./
# RUN npm install
# COPY . .
# EXPOSE 5000
# CMD ["npm", "start"]
# Stage 1: Build
# Stage 1: Install dependencies
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Copy source code & run
FROM node:18-alpine
WORKDIR /app

# Copy only needed files
COPY --from=deps /app/node_modules ./node_modules
COPY . .

EXPOSE 5000
CMD ["node", "index.js"]

