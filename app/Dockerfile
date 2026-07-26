FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY index.js .

FROM gcr.io/distroless/nodejs22-debian12
ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA
COPY --from=build /app /app
WORKDIR /app
USER nonroot
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=2 \
  CMD ["/nodejs/bin/node", "-e", "require('http').get('http://localhost:3000/healthz', r => {process.exit(r.statusCode===200?0:1)})"]
EXPOSE 3000
CMD ["index.js"]
