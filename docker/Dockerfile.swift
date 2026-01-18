FROM swift:5.9
LABEL org.opencontainers.image.description="Human Lang - Swift Implementation"

WORKDIR /app
COPY swift/rate_limiter.swift .

RUN swiftc -O -o rate_limiter rate_limiter.swift

CMD ["./rate_limiter"]
