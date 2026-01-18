/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 *
 * Groovy: Java's cooler younger sibling.
 */

import java.util.concurrent.locks.ReentrantLock

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 */
class TokenBucket {
    final double capacity
    final double refillRate
    private double tokens
    private long lastRefill
    private final ReentrantLock lock = new ReentrantLock()

    TokenBucket(double capacity, double refillRate) {
        assert capacity > 0 : "Capacity must be positive"
        assert refillRate > 0 : "Refill rate must be positive"

        this.capacity = capacity
        this.refillRate = refillRate
        this.tokens = capacity  // Start full
        this.lastRefill = System.nanoTime()
    }

    private void refill() {
        def now = System.nanoTime()
        def elapsedNs = now - lastRefill

        if (elapsedNs > 0) {
            def elapsedSec = elapsedNs / 1e9
            def tokensToAdd = elapsedSec * refillRate
            tokens = Math.min(capacity, tokens + tokensToAdd)
            lastRefill = now
        }
    }

    boolean consume(double n = 1.0) {
        lock.lock()
        try {
            refill()
            if (tokens >= n) {
                tokens -= n
                return true
            }
            return false
        } finally {
            lock.unlock()
        }
    }

    double available() {
        lock.lock()
        try {
            refill()
            return tokens
        } finally {
            lock.unlock()
        }
    }
}

// --- Demonstration ---

println "Token Bucket Rate Limiter - Groovy Implementation"
println "=" * 50
println()

// Create a bucket: 5 tokens capacity, 2 tokens/second refill
def limiter = new TokenBucket(5, 2)

println "Created limiter: capacity=${(int)limiter.capacity}, refill_rate=${(int)limiter.refillRate}/s"
println "Starting tokens: ${(int)limiter.available()}"
println()

// Consume all tokens rapidly
println "--- Rapid consumption ---"
(1..7).each { i ->
    def result = limiter.consume()
    def status = result ? "✓ allowed" : "✗ denied"
    printf "  Attempt %d: %s (tokens left: %.2f)%n", i, status, limiter.available()
}
println()

// Wait for refill
println "--- Waiting 1 second for refill ---"
Thread.sleep(1000)
printf "Tokens after 1s: %.2f%n", limiter.available()
println()

// Try again
println "--- Post-refill consumption ---"
(1..3).each { i ->
    def result = limiter.consume()
    def status = result ? "✓ allowed" : "✗ denied"
    printf "  Attempt %d: %s (tokens left: %.2f)%n", i, status, limiter.available()
}
println()

println "=" * 50
println "Human intent → Groovy implementation ✓"
