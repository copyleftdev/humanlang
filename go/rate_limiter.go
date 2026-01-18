// Package main implements a Token Bucket Rate Limiter
//
// Transpiled from INTENT.md - Human language is the source code.
package main

import (
	"fmt"
	"strings"
	"sync"
	"time"
)

// TokenBucket is a rate limiter using the token bucket algorithm.
//
// Tokens refill at a steady rate up to a maximum capacity.
// Each action consumes one token. If no tokens are available,
// the action is denied.
type TokenBucket struct {
	capacity   float64
	refillRate float64
	tokens     float64
	lastRefill time.Time
	mu         sync.Mutex
}

// NewTokenBucket creates a new token bucket rate limiter.
//
// Parameters:
//   - capacity: Maximum number of tokens the bucket can hold
//   - refillRate: Number of tokens added per second
func NewTokenBucket(capacity, refillRate float64) *TokenBucket {
	if capacity <= 0 {
		panic("capacity must be positive")
	}
	if refillRate <= 0 {
		panic("refill rate must be positive")
	}

	return &TokenBucket{
		capacity:   capacity,
		refillRate: refillRate,
		tokens:     capacity, // Start full
		lastRefill: time.Now(),
	}
}

// refill adds tokens based on elapsed time since last refill.
func (tb *TokenBucket) refill() {
	now := time.Now()
	elapsed := now.Sub(tb.lastRefill).Seconds()

	// Guard against clock issues
	if elapsed > 0 {
		tokensToAdd := elapsed * tb.refillRate
		tb.tokens = min(tb.capacity, tb.tokens+tokensToAdd)
		tb.lastRefill = now
	}
}

// Consume attempts to consume tokens from the bucket.
//
// Parameters:
//   - tokens: Number of tokens to consume
//
// Returns true if tokens were consumed, false if insufficient tokens.
func (tb *TokenBucket) Consume(tokens float64) bool {
	tb.mu.Lock()
	defer tb.mu.Unlock()

	tb.refill()

	if tb.tokens >= tokens {
		tb.tokens -= tokens
		return true
	}
	return false
}

// ConsumeOne attempts to consume a single token.
func (tb *TokenBucket) ConsumeOne() bool {
	return tb.Consume(1.0)
}

// Available returns the current number of available tokens.
func (tb *TokenBucket) Available() float64 {
	tb.mu.Lock()
	defer tb.mu.Unlock()

	tb.refill()
	return tb.tokens
}

// Capacity returns the maximum capacity of the bucket.
func (tb *TokenBucket) Capacity() float64 {
	return tb.capacity
}

// RefillRate returns the token refill rate (tokens per second).
func (tb *TokenBucket) RefillRate() float64 {
	return tb.refillRate
}

// --- Demonstration ---

func main() {
	fmt.Println("Token Bucket Rate Limiter - Go Implementation")
	fmt.Println(strings.Repeat("=", 50))

	// Create a bucket: 5 tokens capacity, 2 tokens/second refill
	limiter := NewTokenBucket(5, 2)

	fmt.Printf("\nCreated limiter: capacity=%.0f, refill_rate=%.0f/s\n",
		limiter.Capacity(), limiter.RefillRate())
	fmt.Printf("Starting tokens: %.0f\n", limiter.Available())

	// Consume all tokens rapidly
	fmt.Println("\n--- Rapid consumption ---")
	for i := 0; i < 7; i++ {
		result := limiter.ConsumeOne()
		status := "✗ denied"
		if result {
			status = "✓ allowed"
		}
		fmt.Printf("  Attempt %d: %s (tokens left: %.2f)\n",
			i+1, status, limiter.Available())
	}

	// Wait for refill
	fmt.Println("\n--- Waiting 1 second for refill ---")
	time.Sleep(1 * time.Second)
	fmt.Printf("Tokens after 1s: %.2f\n", limiter.Available())

	// Try again
	fmt.Println("\n--- Post-refill consumption ---")
	for i := 0; i < 3; i++ {
		result := limiter.ConsumeOne()
		status := "✗ denied"
		if result {
			status = "✓ allowed"
		}
		fmt.Printf("  Attempt %d: %s (tokens left: %.2f)\n",
			i+1, status, limiter.Available())
	}

	fmt.Println()
	fmt.Println(strings.Repeat("=", 50))
	fmt.Println("Human intent → Go implementation ✓")
}
