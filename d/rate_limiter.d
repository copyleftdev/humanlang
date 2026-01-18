/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 *
 * D: The language that fixed C++. Systems programming with a smile.
 */

import std.stdio;
import std.format;
import core.time;
import core.thread;
import core.sync.mutex;

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 */
class TokenBucket {
    private double capacity_;
    private double refillRate_;
    private double tokens_;
    private MonoTime lastRefill_;
    private Mutex mutex_;

    /**
     * Create a new token bucket.
     *
     * Params:
     *   capacity = Maximum number of tokens the bucket can hold
     *   refillRate = Number of tokens added per second
     */
    this(double capacity, double refillRate) {
        assert(capacity > 0, "Capacity must be positive");
        assert(refillRate > 0, "Refill rate must be positive");

        capacity_ = capacity;
        refillRate_ = refillRate;
        tokens_ = capacity;  // Start full
        lastRefill_ = MonoTime.currTime;
        mutex_ = new Mutex();
    }

    private void refill() {
        auto now = MonoTime.currTime;
        auto elapsed = (now - lastRefill_).total!"nsecs" / 1e9;

        if (elapsed > 0) {
            auto tokensToAdd = elapsed * refillRate_;
            tokens_ = tokens_ + tokensToAdd;
            if (tokens_ > capacity_) tokens_ = capacity_;
            lastRefill_ = now;
        }
    }

    /**
     * Attempt to consume tokens from the bucket.
     *
     * Params:
     *   tokens = Number of tokens to consume (default: 1)
     *
     * Returns: true if tokens were consumed, false if insufficient
     */
    bool consume(double tokens = 1.0) {
        mutex_.lock();
        scope(exit) mutex_.unlock();

        refill();

        if (tokens_ >= tokens) {
            tokens_ -= tokens;
            return true;
        }
        return false;
    }

    /**
     * Get the current number of available tokens.
     */
    double available() {
        mutex_.lock();
        scope(exit) mutex_.unlock();

        refill();
        return tokens_;
    }

    @property double capacity() { return capacity_; }
    @property double refillRate() { return refillRate_; }
}

// --- Demonstration ---

void main() {
    writeln("Token Bucket Rate Limiter - D Implementation");
    foreach (_; 0 .. 50) write("=");
    writeln();
    writeln();

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    auto limiter = new TokenBucket(5, 2);

    writefln("Created limiter: capacity=%.0f, refill_rate=%.0f/s",
             limiter.capacity, limiter.refillRate);
    writefln("Starting tokens: %.0f", limiter.available());
    writeln();

    // Consume all tokens rapidly
    writeln("--- Rapid consumption ---");
    foreach (i; 1 .. 8) {
        auto result = limiter.consume();
        auto status = result ? "✓ allowed" : "✗ denied";
        writefln("  Attempt %d: %s (tokens left: %.2f)",
                 i, status, limiter.available());
    }
    writeln();

    // Wait for refill
    writeln("--- Waiting 1 second for refill ---");
    Thread.sleep(1.seconds);
    writefln("Tokens after 1s: %.2f", limiter.available());
    writeln();

    // Try again
    writeln("--- Post-refill consumption ---");
    foreach (i; 1 .. 4) {
        auto result = limiter.consume();
        auto status = result ? "✓ allowed" : "✗ denied";
        writefln("  Attempt %d: %s (tokens left: %.2f)",
                 i, status, limiter.available());
    }
    writeln();

    foreach (_; 0 .. 50) write("=");
    writeln();
    writeln("Human intent → D implementation ✓");
}
