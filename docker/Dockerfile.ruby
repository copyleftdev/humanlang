FROM ruby:3.3-slim
LABEL org.opencontainers.image.description="Human Lang - Ruby Implementation"

WORKDIR /app
COPY ruby/rate_limiter.rb .

CMD ["ruby", "rate_limiter.rb"]
