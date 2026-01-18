FROM bash:5
LABEL org.opencontainers.image.description="Human Lang - Bash Implementation"

RUN apk add --no-cache bc coreutils

WORKDIR /app
COPY bash/rate_limiter.sh .
RUN chmod +x rate_limiter.sh

CMD ["bash", "rate_limiter.sh"]
