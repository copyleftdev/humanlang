# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.

using Printf
using Base.Threads: SpinLock

"""
A rate limiter using the token bucket algorithm.

Tokens refill at a steady rate up to a maximum capacity.
Each action consumes one token. If no tokens are available,
the action is denied.
"""
mutable struct TokenBucket
    const capacity::Float64
    const refill_rate::Float64
    tokens::Float64
    last_refill::Float64
    lock::SpinLock

    """
    Create a new token bucket.

    - capacity: Maximum number of tokens the bucket can hold
    - refill_rate: Number of tokens added per second
    """
    function TokenBucket(capacity::Real, refill_rate::Real)
        capacity > 0 || throw(ArgumentError("Capacity must be positive"))
        refill_rate > 0 || throw(ArgumentError("Refill rate must be positive"))
        
        new(
            Float64(capacity),
            Float64(refill_rate),
            Float64(capacity),  # Start full
            time(),
            SpinLock()
        )
    end
end

"""
Add tokens based on elapsed time since last refill.
"""
function refill!(bucket::TokenBucket)
    now = time()
    elapsed = now - bucket.last_refill

    if elapsed > 0
        tokens_to_add = elapsed * bucket.refill_rate
        bucket.tokens = min(bucket.capacity, bucket.tokens + tokens_to_add)
        bucket.last_refill = now
    end
end

"""
Attempt to consume tokens from the bucket.

Returns true if tokens were consumed, false if insufficient.
"""
function consume!(bucket::TokenBucket, tokens::Real=1.0)::Bool
    lock(bucket.lock) do
        refill!(bucket)

        if bucket.tokens >= tokens
            bucket.tokens -= tokens
            return true
        end
        return false
    end
end

"""
Get the current number of available tokens.
"""
function available(bucket::TokenBucket)::Float64
    lock(bucket.lock) do
        refill!(bucket)
        return bucket.tokens
    end
end

# --- Demonstration ---

function main()
    println("Token Bucket Rate Limiter - Julia Implementation")
    println("=" ^ 50)
    println()

    # Create a bucket: 5 tokens capacity, 2 tokens/second refill
    limiter = TokenBucket(5, 2)

    println("Created limiter: capacity=$(Int(limiter.capacity)), refill_rate=$(Int(limiter.refill_rate))/s")
    println("Starting tokens: $(Int(available(limiter)))")
    println()

    # Consume all tokens rapidly
    println("--- Rapid consumption ---")
    for i in 1:7
        result = consume!(limiter)
        status = result ? "✓ allowed" : "✗ denied"
        @printf("  Attempt %d: %s (tokens left: %.2f)\n", i, status, available(limiter))
    end
    println()

    # Wait for refill
    println("--- Waiting 1 second for refill ---")
    sleep(1)
    @printf("Tokens after 1s: %.2f\n", available(limiter))
    println()

    # Try again
    println("--- Post-refill consumption ---")
    for i in 1:3
        result = consume!(limiter)
        status = result ? "✓ allowed" : "✗ denied"
        @printf("  Attempt %d: %s (tokens left: %.2f)\n", i, status, available(limiter))
    end
    println()

    println("=" ^ 50)
    println("Human intent → Julia implementation ✓")
end

main()
