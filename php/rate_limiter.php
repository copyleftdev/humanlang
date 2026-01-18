<?php
/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 *
 * PHP: The language that powers 80% of the web.
 * Human intent, served billions of times per day.
 */

declare(strict_types=1);

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 */
class TokenBucket
{
    private float $capacity;
    private float $refillRate;
    private float $tokens;
    private float $lastRefill;

    /**
     * Create a new token bucket.
     *
     * @param float $capacity Maximum number of tokens the bucket can hold
     * @param float $refillRate Number of tokens added per second
     */
    public function __construct(float $capacity, float $refillRate)
    {
        if ($capacity <= 0) {
            throw new InvalidArgumentException('Capacity must be positive');
        }
        if ($refillRate <= 0) {
            throw new InvalidArgumentException('Refill rate must be positive');
        }

        $this->capacity = $capacity;
        $this->refillRate = $refillRate;
        $this->tokens = $capacity;  // Start full
        $this->lastRefill = hrtime(true) / 1e9;
    }

    /**
     * Add tokens based on elapsed time since last refill.
     */
    private function refill(): void
    {
        $now = hrtime(true) / 1e9;
        $elapsed = $now - $this->lastRefill;

        if ($elapsed > 0) {
            $tokensToAdd = $elapsed * $this->refillRate;
            $this->tokens = min($this->capacity, $this->tokens + $tokensToAdd);
            $this->lastRefill = $now;
        }
    }

    /**
     * Attempt to consume tokens from the bucket.
     *
     * @param float $tokens Number of tokens to consume (default: 1)
     * @return bool True if tokens were consumed, false if insufficient
     */
    public function consume(float $tokens = 1.0): bool
    {
        $this->refill();

        if ($this->tokens >= $tokens) {
            $this->tokens -= $tokens;
            return true;
        }
        return false;
    }

    /**
     * Get the current number of available tokens.
     */
    public function available(): float
    {
        $this->refill();
        return $this->tokens;
    }

    public function getCapacity(): float
    {
        return $this->capacity;
    }

    public function getRefillRate(): float
    {
        return $this->refillRate;
    }
}

// --- Demonstration ---

echo "Token Bucket Rate Limiter - PHP Implementation\n";
echo str_repeat("=", 50) . "\n\n";

// Create a bucket: 5 tokens capacity, 2 tokens/second refill
$limiter = new TokenBucket(5, 2);

printf("Created limiter: capacity=%d, refill_rate=%d/s\n",
       $limiter->getCapacity(), $limiter->getRefillRate());
printf("Starting tokens: %d\n\n", $limiter->available());

// Consume all tokens rapidly
echo "--- Rapid consumption ---\n";
for ($i = 1; $i <= 7; $i++) {
    $result = $limiter->consume();
    $status = $result ? "✓ allowed" : "✗ denied";
    printf("  Attempt %d: %s (tokens left: %.2f)\n",
           $i, $status, $limiter->available());
}
echo "\n";

// Wait for refill
echo "--- Waiting 1 second for refill ---\n";
sleep(1);
printf("Tokens after 1s: %.2f\n\n", $limiter->available());

// Try again
echo "--- Post-refill consumption ---\n";
for ($i = 1; $i <= 3; $i++) {
    $result = $limiter->consume();
    $status = $result ? "✓ allowed" : "✗ denied";
    printf("  Attempt %d: %s (tokens left: %.2f)\n",
           $i, $status, $limiter->available());
}
echo "\n";

echo str_repeat("=", 50) . "\n";
echo "Human intent → PHP implementation ✓\n";
