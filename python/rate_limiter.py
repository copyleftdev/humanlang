"""
Token Bucket Rate Limiter

Transpiled from INTENT.md - Human language is the source code.
"""

import time
import threading
from typing import Optional


class TokenBucket:
    """
    A rate limiter using the token bucket algorithm.
    
    Tokens refill at a steady rate up to a maximum capacity.
    Each action consumes one token. If no tokens are available,
    the action is denied.
    """
    
    def __init__(self, capacity: float, refill_rate: float):
        """
        Create a new token bucket.
        
        Args:
            capacity: Maximum number of tokens the bucket can hold
            refill_rate: Number of tokens added per second
        """
        if capacity <= 0:
            raise ValueError("Capacity must be positive")
        if refill_rate <= 0:
            raise ValueError("Refill rate must be positive")
            
        self._capacity = capacity
        self._refill_rate = refill_rate
        self._tokens = capacity  # Start full
        self._last_refill = time.monotonic()
        self._lock = threading.Lock()
    
    def _refill(self) -> None:
        """Add tokens based on elapsed time since last refill."""
        now = time.monotonic()
        elapsed = now - self._last_refill
        
        # Guard against clock issues (time going backwards)
        if elapsed > 0:
            tokens_to_add = elapsed * self._refill_rate
            self._tokens = min(self._capacity, self._tokens + tokens_to_add)
            self._last_refill = now
    
    def consume(self, tokens: float = 1.0) -> bool:
        """
        Attempt to consume tokens from the bucket.
        
        Args:
            tokens: Number of tokens to consume (default: 1)
            
        Returns:
            True if tokens were consumed, False if insufficient tokens
        """
        with self._lock:
            self._refill()
            
            if self._tokens >= tokens:
                self._tokens -= tokens
                return True
            return False
    
    def available(self) -> float:
        """
        Get the current number of available tokens.
        
        Returns:
            Number of tokens currently in the bucket
        """
        with self._lock:
            self._refill()
            return self._tokens
    
    @property
    def capacity(self) -> float:
        """Maximum capacity of the bucket."""
        return self._capacity
    
    @property
    def refill_rate(self) -> float:
        """Token refill rate (tokens per second)."""
        return self._refill_rate


# --- Demonstration ---

if __name__ == "__main__":
    print("Token Bucket Rate Limiter - Python Implementation")
    print("=" * 50)
    
    # Create a bucket: 5 tokens capacity, 2 tokens/second refill
    limiter = TokenBucket(capacity=5, refill_rate=2)
    
    print(f"\nCreated limiter: capacity={limiter.capacity}, refill_rate={limiter.refill_rate}/s")
    print(f"Starting tokens: {limiter.available()}")
    
    # Consume all tokens rapidly
    print("\n--- Rapid consumption ---")
    for i in range(7):
        result = limiter.consume()
        print(f"  Attempt {i+1}: {'✓ allowed' if result else '✗ denied'} (tokens left: {limiter.available():.2f})")
    
    # Wait for refill
    print("\n--- Waiting 1 second for refill ---")
    time.sleep(1)
    print(f"Tokens after 1s: {limiter.available():.2f}")
    
    # Try again
    print("\n--- Post-refill consumption ---")
    for i in range(3):
        result = limiter.consume()
        print(f"  Attempt {i+1}: {'✓ allowed' if result else '✗ denied'} (tokens left: {limiter.available():.2f})")
    
    print("\n" + "=" * 50)
    print("Human intent → Python implementation ✓")
