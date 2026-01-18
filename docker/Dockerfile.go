FROM golang:1.22-alpine
LABEL org.opencontainers.image.description="Human Lang - Go Implementation"

WORKDIR /app
COPY go/ .

RUN go build -o rate_limiter rate_limiter.go

CMD ["./rate_limiter"]
