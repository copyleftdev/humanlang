/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 */

import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 *
 * @property capacity Maximum number of tokens the bucket can hold
 * @property refillRate Number of tokens added per second
 */
class TokenBucket(
    val capacity: Double,
    val refillRate: Double
) {
    init {
        require(capacity > 0) { "Capacity must be positive" }
        require(refillRate > 0) { "Refill rate must be positive" }
    }

    private var tokens: Double = capacity  // Start full
    private var lastRefill: Long = System.nanoTime()
    private val lock = ReentrantLock()

    /**
     * Add tokens based on elapsed time since last refill.
     */
    private fun refill() {
        val now = System.nanoTime()
        val elapsedNs = now - lastRefill

        if (elapsedNs > 0) {
            val elapsedSec = elapsedNs / 1_000_000_000.0
            val tokensToAdd = elapsedSec * refillRate
            tokens = minOf(capacity, tokens + tokensToAdd)
            lastRefill = now
        }
    }

    /**
     * Attempt to consume tokens from the bucket.
     *
     * @param tokenCount Number of tokens to consume (default: 1)
     * @return true if tokens were consumed, false if insufficient
     */
    fun consume(tokenCount: Double = 1.0): Boolean = lock.withLock {
        refill()

        if (tokens >= tokenCount) {
            tokens -= tokenCount
            true
        } else {
            false
        }
    }

    /**
     * Get the current number of available tokens.
     */
    fun available(): Double = lock.withLock {
        refill()
        tokens
    }
}

// --- Demonstration ---

fun main() {
    println("Token Bucket Rate Limiter - Kotlin Implementation")
    println("=".repeat(50))

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    val limiter = TokenBucket(capacity = 5.0, refillRate = 2.0)

    println()
    println("Created limiter: capacity=${limiter.capacity.toInt()}, refill_rate=${limiter.refillRate.toInt()}/s")
    println("Starting tokens: ${limiter.available().toInt()}")

    // Consume all tokens rapidly
    println()
    println("--- Rapid consumption ---")
    repeat(7) { i ->
        val result = limiter.consume()
        val status = if (result) "✓ allowed" else "✗ denied"
        println("  Attempt ${i + 1}: $status (tokens left: ${"%.2f".format(limiter.available())})")
    }

    // Wait for refill
    println()
    println("--- Waiting 1 second for refill ---")
    Thread.sleep(1000)
    println("Tokens after 1s: ${"%.2f".format(limiter.available())}")

    // Try again
    println()
    println("--- Post-refill consumption ---")
    repeat(3) { i ->
        val result = limiter.consume()
        val status = if (result) "✓ allowed" else "✗ denied"
        println("  Attempt ${i + 1}: $status (tokens left: ${"%.2f".format(limiter.available())})")
    }

    println()
    println("=".repeat(50))
    println("Human intent → Kotlin implementation ✓")
}
