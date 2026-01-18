FROM debian:bookworm-slim
LABEL org.opencontainers.image.description="Human Lang - COBOL Implementation"

RUN apt-get update && \
    apt-get install -y gnucobol && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY cobol/RATELIMIT.cbl .

RUN cobc -x -free -o rate_limiter RATELIMIT.cbl

CMD ["./rate_limiter"]
