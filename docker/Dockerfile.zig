FROM alpine:3.19
LABEL org.opencontainers.image.description="Human Lang - Zig Implementation"

RUN apk add --no-cache zig

WORKDIR /app
COPY zig/rate_limiter.zig .

RUN zig build-exe rate_limiter.zig -O ReleaseFast

CMD ["./rate_limiter"]
