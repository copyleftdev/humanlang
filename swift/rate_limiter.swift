// Token Bucket Rate Limiter
//
// Transpiled from INTENT.md - Human language is the source code.

import Foundation

/// A rate limiter using the token bucket algorithm.
///
/// Tokens refill at a steady rate up to a maximum capacity.
/// Each action consumes one token. If no tokens are available,
/// the action is denied.
class TokenBucket {
    let capacity: Double
    let refillRate: Double
    private var tokens: Double
    private var lastRefill: TimeInterval
    private let lock = NSLock()

    /// Create a new token bucket.
    ///
    /// - Parameters:
    ///   - capacity: Maximum number of tokens the bucket can hold
    ///   - refillRate: Number of tokens added per second
    init(capacity: Double, refillRate: Double) {
        precondition(capacity > 0, "Capacity must be positive")
        precondition(refillRate > 0, "Refill rate must be positive")

        self.capacity = capacity
        self.refillRate = refillRate
        self.tokens = capacity  // Start full
        self.lastRefill = ProcessInfo.processInfo.systemUptime
    }

    /// Add tokens based on elapsed time since last refill.
    private func refill() {
        let now = ProcessInfo.processInfo.systemUptime
        let elapsed = now - lastRefill

        if elapsed > 0 {
            let tokensToAdd = elapsed * refillRate
            tokens = min(capacity, tokens + tokensToAdd)
            lastRefill = now
        }
    }

    /// Attempt to consume tokens from the bucket.
    ///
    /// - Parameter tokens: Number of tokens to consume (default: 1)
    /// - Returns: true if tokens were consumed, false if insufficient
    func consume(_ tokenCount: Double = 1.0) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        refill()

        if tokens >= tokenCount {
            tokens -= tokenCount
            return true
        }
        return false
    }

    /// Get the current number of available tokens.
    var available: Double {
        lock.lock()
        defer { lock.unlock() }

        refill()
        return tokens
    }
}

// --- Demonstration ---

func main() {
    print("Token Bucket Rate Limiter - Swift Implementation")
    print(String(repeating: "=", count: 50))

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    let limiter = TokenBucket(capacity: 5, refillRate: 2)

    print()
    print("Created limiter: capacity=\(Int(limiter.capacity)), refill_rate=\(Int(limiter.refillRate))/s")
    print("Starting tokens: \(Int(limiter.available))")

    // Consume all tokens rapidly
    print()
    print("--- Rapid consumption ---")
    for i in 1...7 {
        let result = limiter.consume()
        let status = result ? "✓ allowed" : "✗ denied"
        print("  Attempt \(i): \(status) (tokens left: \(String(format: "%.2f", limiter.available)))")
    }

    // Wait for refill
    print()
    print("--- Waiting 1 second for refill ---")
    Thread.sleep(forTimeInterval: 1.0)
    print("Tokens after 1s: \(String(format: "%.2f", limiter.available))")

    // Try again
    print()
    print("--- Post-refill consumption ---")
    for i in 1...3 {
        let result = limiter.consume()
        let status = result ? "✓ allowed" : "✗ denied"
        print("  Attempt \(i): \(status) (tokens left: \(String(format: "%.2f", limiter.available)))")
    }

    print()
    print(String(repeating: "=", count: 50))
    print("Human intent → Swift implementation ✓")
}

main()
