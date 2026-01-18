FROM nimlang/nim:2.0.2
LABEL org.opencontainers.image.description="Human Lang - Nim Implementation"

WORKDIR /app
COPY nim/rate_limiter.nim .

RUN nim c -d:release rate_limiter.nim

CMD ["./rate_limiter"]
