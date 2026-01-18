FROM r-base:4.3.2
LABEL org.opencontainers.image.description="Human Lang - R Implementation"

RUN R -e "install.packages('R6', repos='https://cloud.r-project.org/')"

WORKDIR /app
COPY r/rate_limiter.R .

CMD ["Rscript", "rate_limiter.R"]
