FROM alpine:3.19
LABEL org.opencontainers.image.description="Human Lang - Lua Implementation"

RUN apk add --no-cache lua5.4 lua5.4-socket

WORKDIR /app
COPY lua/rate_limiter.lua .

CMD ["lua5.4", "rate_limiter.lua"]
