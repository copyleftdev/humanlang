//! Token Bucket Rate Limiter
//!
//! Transpiled from INTENT.md - Human language is the source code.

use std::sync::Mutex;
use std::time::Instant;
use std::thread;
use std::time::Duration;

/// A rate limiter using the token bucket algorithm.
///
/// Tokens refill at a steady rate up to a maximum capacity.
/// Each action consumes one token. If no tokens are available,
/// the action is denied.
pub struct TokenBucket {
    capacity: f64,
    refill_rate: f64,
    state: Mutex<BucketState>,
}

struct BucketState {
    tokens: f64,
    last_refill: Instant,
}

impl TokenBucket {
    /// Create a new token bucket.
    ///
    /// # Arguments
    /// * `capacity` - Maximum number of tokens the bucket can hold
    /// * `refill_rate` - Number of tokens added per second
    ///
    /// # Panics
    /// Panics if capacity or refill_rate are not positive
    pub fn new(capacity: f64, refill_rate: f64) -> Self {
        assert!(capacity > 0.0, "Capacity must be positive");
        assert!(refill_rate > 0.0, "Refill rate must be positive");

        TokenBucket {
            capacity,
            refill_rate,
            state: Mutex::new(BucketState {
                tokens: capacity, // Start full
                last_refill: Instant::now(),
            }),
        }
    }

    /// Add tokens based on elapsed time since last refill.
    fn refill(state: &mut BucketState, capacity: f64, refill_rate: f64) {
        let now = Instant::now();
        let elapsed = now.duration_since(state.last_refill).as_secs_f64();

        // Elapsed is always non-negative with Instant
        if elapsed > 0.0 {
            let tokens_to_add = elapsed * refill_rate;
            state.tokens = (state.tokens + tokens_to_add).min(capacity);
            state.last_refill = now;
        }
    }

    /// Attempt to consume tokens from the bucket.
    ///
    /// # Arguments
    /// * `tokens` - Number of tokens to consume (default: 1.0)
    ///
    /// # Returns
    /// `true` if tokens were consumed, `false` if insufficient tokens
    pub fn consume(&self, tokens: f64) -> bool {
        let mut state = self.state.lock().unwrap();
        Self::refill(&mut state, self.capacity, self.refill_rate);

        if state.tokens >= tokens {
            state.tokens -= tokens;
            true
        } else {
            false
        }
    }

    /// Consume a single token.
    pub fn consume_one(&self) -> bool {
        self.consume(1.0)
    }

    /// Get the current number of available tokens.
    pub fn available(&self) -> f64 {
        let mut state = self.state.lock().unwrap();
        Self::refill(&mut state, self.capacity, self.refill_rate);
        state.tokens
    }

    /// Maximum capacity of the bucket.
    pub fn capacity(&self) -> f64 {
        self.capacity
    }

    /// Token refill rate (tokens per second).
    pub fn refill_rate(&self) -> f64 {
        self.refill_rate
    }
}

// --- Demonstration ---

fn main() {
    println!("Token Bucket Rate Limiter - Rust Implementation");
    println!("{}", "=".repeat(50));

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    let limiter = TokenBucket::new(5.0, 2.0);

    println!("\nCreated limiter: capacity={}, refill_rate={}/s", 
             limiter.capacity(), limiter.refill_rate());
    println!("Starting tokens: {}", limiter.available());

    // Consume all tokens rapidly
    println!("\n--- Rapid consumption ---");
    for i in 0..7 {
        let result = limiter.consume_one();
        println!("  Attempt {}: {} (tokens left: {:.2})",
                 i + 1,
                 if result { "✓ allowed" } else { "✗ denied" },
                 limiter.available());
    }

    // Wait for refill
    println!("\n--- Waiting 1 second for refill ---");
    thread::sleep(Duration::from_secs(1));
    println!("Tokens after 1s: {:.2}", limiter.available());

    // Try again
    println!("\n--- Post-refill consumption ---");
    for i in 0..3 {
        let result = limiter.consume_one();
        println!("  Attempt {}: {} (tokens left: {:.2})",
                 i + 1,
                 if result { "✓ allowed" } else { "✗ denied" },
                 limiter.available());
    }

    println!("\n{}", "=".repeat(50));
    println!("Human intent → Rust implementation ✓");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_initial_capacity() {
        let bucket = TokenBucket::new(10.0, 1.0);
        assert_eq!(bucket.available(), 10.0);
    }

    #[test]
    fn test_consume_success() {
        let bucket = TokenBucket::new(5.0, 1.0);
        assert!(bucket.consume_one());
        assert!(bucket.available() < 5.0);
    }

    #[test]
    fn test_consume_failure_when_empty() {
        let bucket = TokenBucket::new(2.0, 0.1);
        assert!(bucket.consume_one());
        assert!(bucket.consume_one());
        assert!(!bucket.consume_one());
    }

    #[test]
    #[should_panic]
    fn test_invalid_capacity() {
        TokenBucket::new(0.0, 1.0);
    }

    #[test]
    #[should_panic]
    fn test_invalid_refill_rate() {
        TokenBucket::new(1.0, 0.0);
    }
}
