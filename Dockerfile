# Multi-stage Dockerfile to build client and backend, then run production server
FROM node:16 AS builder
WORKDIR /app

# Install root dependencies (including dev for tsc)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Build frontend
COPY client ./client
RUN cd client && yarn install --frozen-lockfile && yarn build

# Copy rest of the source and compile TypeScript backend
COPY . .
RUN rm -rf public || true
RUN mkdir -p public
RUN cp -r client/build/* public/
RUN yarn tsc

FROM node:16-alpine
WORKDIR /app
ENV NODE_ENV=production

# Install production dependencies only
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile

# Copy app files from builder
COPY --from=builder /app .

EXPOSE 8000
CMD ["node", "dist/app.js"]
