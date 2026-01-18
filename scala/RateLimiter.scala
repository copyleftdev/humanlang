/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 */

import java.util.concurrent.locks.ReentrantLock

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 *
 * @param capacity Maximum number of tokens the bucket can hold
 * @param refillRate Number of tokens added per second
 */
class TokenBucket(val capacity: Double, val refillRate: Double) {
  require(capacity > 0, "Capacity must be positive")
  require(refillRate > 0, "Refill rate must be positive")

  private var tokens: Double = capacity // Start full
  private var lastRefill: Long = System.nanoTime()
  private val lock = new ReentrantLock()

  /**
   * Add tokens based on elapsed time since last refill.
   */
  private def refill(): Unit = {
    val now = System.nanoTime()
    val elapsedNs = now - lastRefill

    if (elapsedNs > 0) {
      val elapsedSec = elapsedNs / 1e9
      val tokensToAdd = elapsedSec * refillRate
      tokens = math.min(capacity, tokens + tokensToAdd)
      lastRefill = now
    }
  }

  /**
   * Attempt to consume tokens from the bucket.
   *
   * @param tokenCount Number of tokens to consume (default: 1)
   * @return true if tokens were consumed, false if insufficient
   */
  def consume(tokenCount: Double = 1.0): Boolean = {
    lock.lock()
    try {
      refill()

      if (tokens >= tokenCount) {
        tokens -= tokenCount
        true
      } else {
        false
      }
    } finally {
      lock.unlock()
    }
  }

  /**
   * Get the current number of available tokens.
   */
  def available: Double = {
    lock.lock()
    try {
      refill()
      tokens
    } finally {
      lock.unlock()
    }
  }
}

// --- Demonstration ---

object RateLimiter extends App {
  println("Token Bucket Rate Limiter - Scala Implementation")
  println("=" * 50)

  // Create a bucket: 5 tokens capacity, 2 tokens/second refill
  val limiter = new TokenBucket(capacity = 5, refillRate = 2)

  println()
  println(s"Created limiter: capacity=${limiter.capacity.toInt}, refill_rate=${limiter.refillRate.toInt}/s")
  println(s"Starting tokens: ${limiter.available.toInt}")

  // Consume all tokens rapidly
  println()
  println("--- Rapid consumption ---")
  for (i <- 1 to 7) {
    val result = limiter.consume()
    val status = if (result) "✓ allowed" else "✗ denied"
    println(f"  Attempt $i: $status (tokens left: ${limiter.available}%.2f)")
  }

  // Wait for refill
  println()
  println("--- Waiting 1 second for refill ---")
  Thread.sleep(1000)
  println(f"Tokens after 1s: ${limiter.available}%.2f")

  // Try again
  println()
  println("--- Post-refill consumption ---")
  for (i <- 1 to 3) {
    val result = limiter.consume()
    val status = if (result) "✓ allowed" else "✗ denied"
    println(f"  Attempt $i: $status (tokens left: ${limiter.available}%.2f)")
  }

  println()
  println("=" * 50)
  println("Human intent → Scala implementation ✓")
}
