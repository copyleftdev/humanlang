FROM dart:3.2
LABEL org.opencontainers.image.description="Human Lang - Dart Implementation"

WORKDIR /app
COPY dart/rate_limiter.dart .

CMD ["dart", "run", "rate_limiter.dart"]
