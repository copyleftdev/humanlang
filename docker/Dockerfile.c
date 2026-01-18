FROM gcc:13
LABEL org.opencontainers.image.description="Human Lang - C Implementation"

WORKDIR /app
COPY c/ .

RUN make

CMD ["./rate_limiter"]
