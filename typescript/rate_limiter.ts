/**
 * Token Bucket Rate Limiter
 * 
 * Transpiled from INTENT.md - Human language is the source code.
 */

interface RateLimiter {
  consume(tokens?: number): boolean;
  available(): number;
  readonly capacity: number;
  readonly refillRate: number;
}

class TokenBucket implements RateLimiter {
  private _capacity: number;
  private _refillRate: number;
  private _tokens: number;
  private _lastRefill: number;

  /**
   * Create a new token bucket rate limiter.
   * 
   * @param capacity - Maximum number of tokens the bucket can hold
   * @param refillRate - Number of tokens added per second
   */
  constructor(capacity: number, refillRate: number) {
    if (capacity <= 0) {
      throw new Error('Capacity must be positive');
    }
    if (refillRate <= 0) {
      throw new Error('Refill rate must be positive');
    }

    this._capacity = capacity;
    this._refillRate = refillRate;
    this._tokens = capacity; // Start full
    this._lastRefill = this.now();
  }

  /**
   * Get current time in seconds
   */
  private now(): number {
    if (typeof performance !== 'undefined' && performance.now) {
      return performance.now() / 1000;
    }
    return Date.now() / 1000;
  }

  /**
   * Add tokens based on elapsed time since last refill.
   */
  private refill(): void {
    const now = this.now();
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
   * @param tokens - Number of tokens to consume (default: 1)
   * @returns True if tokens were consumed, false if insufficient
   */
  consume(tokens: number = 1): boolean {
    this.refill();

    if (this._tokens >= tokens) {
      this._tokens -= tokens;
      return true;
    }
    return false;
  }

  /**
   * Get the current number of available tokens.
   * 
   * @returns Number of tokens currently in the bucket
   */
  available(): number {
    this.refill();
    return this._tokens;
  }

  get capacity(): number {
    return this._capacity;
  }

  get refillRate(): number {
    return this._refillRate;
  }
}

// --- Demonstration ---

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main(): Promise<void> {
  console.log('Token Bucket Rate Limiter - TypeScript Implementation');
  console.log('='.repeat(50));

  // Create a bucket: 5 tokens capacity, 2 tokens/second refill
  const limiter: RateLimiter = new TokenBucket(5, 2);

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
  console.log('Human intent → TypeScript implementation ✓');
}

export { TokenBucket, RateLimiter };

main().catch(console.error);
