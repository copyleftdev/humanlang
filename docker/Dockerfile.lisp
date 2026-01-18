FROM clfoundation/sbcl:2.4.0
LABEL org.opencontainers.image.description="Human Lang - Common Lisp Implementation"

RUN apt-get update && apt-get install -y quicklisp && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY lisp/rate_limiter.lisp .

# Create a simplified runner that doesn't need bordeaux-threads
RUN echo '(load "rate_limiter.lisp")' > run.lisp && \
    echo '(demo)' >> run.lisp

CMD ["sbcl", "--script", "run.lisp"]
