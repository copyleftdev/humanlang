FROM gcc:13
LABEL org.opencontainers.image.description="Human Lang - Ada Implementation"

RUN apt-get update && apt-get install -y gnat && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ada/rate_limiter.adb .

RUN gnatmake -O2 rate_limiter.adb

CMD ["./rate_limiter"]
