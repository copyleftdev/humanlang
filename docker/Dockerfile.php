FROM php:8.3-cli
LABEL org.opencontainers.image.description="Human Lang - PHP Implementation"

WORKDIR /app
COPY php/rate_limiter.php .

CMD ["php", "rate_limiter.php"]
