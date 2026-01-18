# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.
#
# R: The language of statisticians and data scientists.
# Even rate limiting can be statistically sound.

#' Token Bucket Rate Limiter
#' 
#' A rate limiter using the token bucket algorithm.
#' Tokens refill at a steady rate up to a maximum capacity.
TokenBucket <- R6::R6Class("TokenBucket",
  public = list(
    capacity = NULL,
    refill_rate = NULL,
    
    initialize = function(capacity, refill_rate) {
      stopifnot("Capacity must be positive" = capacity > 0)
      stopifnot("Refill rate must be positive" = refill_rate > 0)
      
      self$capacity <- capacity
      self$refill_rate <- refill_rate
      private$tokens <- capacity  # Start full
      private$last_refill <- as.numeric(Sys.time())
    },
    
    consume = function(n = 1) {
      private$refill()
      
      if (private$tokens >= n) {
        private$tokens <- private$tokens - n
        return(TRUE)
      }
      return(FALSE)
    },
    
    available = function() {
      private$refill()
      return(private$tokens)
    }
  ),
  
  private = list(
    tokens = NULL,
    last_refill = NULL,
    
    refill = function() {
      now <- as.numeric(Sys.time())
      elapsed <- now - private$last_refill
      
      if (elapsed > 0) {
        tokens_to_add <- elapsed * self$refill_rate
        private$tokens <- min(self$capacity, private$tokens + tokens_to_add)
        private$last_refill <- now
      }
    }
  )
)

# --- Demonstration ---

cat("Token Bucket Rate Limiter - R Implementation\n")
cat(strrep("=", 50), "\n\n")

# Create a bucket: 5 tokens capacity, 2 tokens/second refill
limiter <- TokenBucket$new(capacity = 5, refill_rate = 2)

cat(sprintf("Created limiter: capacity=%d, refill_rate=%d/s\n",
            limiter$capacity, limiter$refill_rate))
cat(sprintf("Starting tokens: %d\n\n", floor(limiter$available())))

# Consume all tokens rapidly
cat("--- Rapid consumption ---\n")
for (i in 1:7) {
  result <- limiter$consume()
  status <- if (result) "✓ allowed" else "✗ denied"
  cat(sprintf("  Attempt %d: %s (tokens left: %.2f)\n",
              i, status, limiter$available()))
}
cat("\n")

# Wait for refill
cat("--- Waiting 1 second for refill ---\n")
Sys.sleep(1)
cat(sprintf("Tokens after 1s: %.2f\n\n", limiter$available()))

# Try again
cat("--- Post-refill consumption ---\n")
for (i in 1:3) {
  result <- limiter$consume()
  status <- if (result) "✓ allowed" else "✗ denied"
  cat(sprintf("  Attempt %d: %s (tokens left: %.2f)\n",
              i, status, limiter$available()))
}
cat("\n")

cat(strrep("=", 50), "\n")
cat("Human intent → R implementation ✓\n")
