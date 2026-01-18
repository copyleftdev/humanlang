FROM perl:5.38
LABEL org.opencontainers.image.description="Human Lang - Perl Implementation"

WORKDIR /app
COPY perl/rate_limiter.pl .

CMD ["perl", "rate_limiter.pl"]
