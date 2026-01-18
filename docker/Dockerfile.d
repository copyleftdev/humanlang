FROM debian:bookworm-slim
LABEL org.opencontainers.image.description="Human Lang - D Implementation"

RUN apt-get update && \
    apt-get install -y wget xz-utils gcc && \
    wget -q https://downloads.dlang.org/releases/2.x/2.107.0/dmd.2.107.0.linux.tar.xz && \
    tar -xf dmd.2.107.0.linux.tar.xz && \
    mv dmd2/linux/bin64/* /usr/local/bin/ && \
    mv dmd2/linux/lib64/* /usr/local/lib/ && \
    rm -rf dmd* /var/lib/apt/lists/*

WORKDIR /app
COPY d/rate_limiter.d .

RUN dmd -of=rate_limiter rate_limiter.d

CMD ["./rate_limiter"]
