FROM swipl:9.2
LABEL org.opencontainers.image.description="Human Lang - Prolog Implementation"

WORKDIR /app
COPY prolog/rate_limiter.pl .

CMD ["swipl", "-g", "demo", "-t", "halt", "rate_limiter.pl"]
