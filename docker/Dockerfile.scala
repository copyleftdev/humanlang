FROM sbtscala/scala-sbt:eclipse-temurin-21.0.2_13_1.9.9_3.4.0
LABEL org.opencontainers.image.description="Human Lang - Scala Implementation"

WORKDIR /app
COPY scala/RateLimiter.scala .

RUN scalac RateLimiter.scala

CMD ["scala", "RateLimiter"]
