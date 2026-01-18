/**
 * Token Bucket Rate Limiter
 * 
 * Transpiled from INTENT.md - Human language is the source code.
 */

class TokenBucket {
  /**
   * Create a new token bucket rate limiter.
   * 
   * @param {number} capacity - Maximum number of tokens the bucket can hold
   * @param {number} refillRate - Number of tokens added per second
   */
  constructor(capacity, refillRate) {
    if (capacity <= 0) {
      throw new Error('Capacity must be positive');
    }
    if (refillRate <= 0) {
      throw new Error('Refill rate must be positive');
    }

    this._capacity = capacity;
    this._refillRate = refillRate;
    this._tokens = capacity; // Start full
    this._lastRefill = this._now();
  }

  /**
   * Get current time in seconds (monotonic-like via performance.now or Date)
   * @returns {number} Current time in seconds
   */
  _now() {
    // Use performance.now() in Node.js/browser for better precision
    if (typeof performance !== 'undefined' && performance.now) {
      return performance.now() / 1000;
    }
    return Date.now() / 1000;
  }

  /**
   * Add tokens based on elapsed time since last refill.
   */
  _refill() {
    const now = this._now();
    const elapsed = now - this._lastRefill;

    // Guard against clock issues
    if (elapsed > 0) {
      const tokensToAdd = elapsed * this._refillRate;
      this._tokens = Math.min(this._capacity, this._tokens + tokensToAdd);
      this._lastRefill = now;
    }
  }

  /**
   * Attempt to consume tokens from the bucket.
   * 
   * @param {number} [tokens=1] - Number of tokens to consume
   * @returns {boolean} True if tokens were consumed, false if insufficient
   */
  consume(tokens = 1) {
    this._refill();

    if (this._tokens >= tokens) {
      this._tokens -= tokens;
      return true;
    }
    return false;
  }

  /**
   * Get the current number of available tokens.
   * 
   * @returns {number} Number of tokens currently in the bucket
   */
  available() {
    this._refill();
    return this._tokens;
  }

  /**
   * Maximum capacity of the bucket.
   * @returns {number}
   */
  get capacity() {
    return this._capacity;
  }

  /**
   * Token refill rate (tokens per second).
   * @returns {number}
   */
  get refillRate() {
    return this._refillRate;
  }
}

// --- Demonstration ---

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  console.log('Token Bucket Rate Limiter - JavaScript Implementation');
  console.log('='.repeat(50));

  // Create a bucket: 5 tokens capacity, 2 tokens/second refill
  const limiter = new TokenBucket(5, 2);

  console.log(`\nCreated limiter: capacity=${limiter.capacity}, refill_rate=${limiter.refillRate}/s`);
  console.log(`Starting tokens: ${limiter.available()}`);

  // Consume all tokens rapidly
  console.log('\n--- Rapid consumption ---');
  for (let i = 0; i < 7; i++) {
    const result = limiter.consume();
    console.log(`  Attempt ${i + 1}: ${result ? '✓ allowed' : '✗ denied'} (tokens left: ${limiter.available().toFixed(2)})`);
  }

  // Wait for refill
  console.log('\n--- Waiting 1 second for refill ---');
  await sleep(1000);
  console.log(`Tokens after 1s: ${limiter.available().toFixed(2)}`);

  // Try again
  console.log('\n--- Post-refill consumption ---');
  for (let i = 0; i < 3; i++) {
    const result = limiter.consume();
    console.log(`  Attempt ${i + 1}: ${result ? '✓ allowed' : '✗ denied'} (tokens left: ${limiter.available().toFixed(2)})`);
  }

  console.log('\n' + '='.repeat(50));
  console.log('Human intent → JavaScript implementation ✓');
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { TokenBucket };
}

// Run demo if executed directly
main().catch(console.error);
