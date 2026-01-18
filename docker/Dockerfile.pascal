FROM debian:bookworm-slim
LABEL org.opencontainers.image.description="Human Lang - Pascal Implementation"

RUN apt-get update && \
    apt-get install -y fpc && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pascal/rate_limiter.pas .

RUN fpc -O2 rate_limiter.pas

CMD ["./rate_limiter"]
