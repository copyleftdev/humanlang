FROM node:20-slim
LABEL org.opencontainers.image.description="Human Lang - JavaScript Implementation"

WORKDIR /app
COPY javascript/rate_limiter.js .

CMD ["node", "rate_limiter.js"]
