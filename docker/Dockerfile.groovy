FROM groovy:4.0-jdk21
LABEL org.opencontainers.image.description="Human Lang - Groovy Implementation"

WORKDIR /app
COPY groovy/RateLimiter.groovy .

CMD ["groovy", "RateLimiter.groovy"]
