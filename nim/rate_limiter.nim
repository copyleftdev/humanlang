# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.

import std/[times, locks, strformat, strutils]

type
  ## A rate limiter using the token bucket algorithm.
  ##
  ## Tokens refill at a steady rate up to a maximum capacity.
  ## Each action consumes one token. If no tokens are available,
  ## the action is denied.
  TokenBucket* = ref object
    capacity*: float
    refillRate*: float
    tokens: float
    lastRefill: float
    lock: Lock

proc getMonoTime(): float =
  ## Get current monotonic time in seconds
  cpuTime()

proc newTokenBucket*(capacity, refillRate: float): TokenBucket =
  ## Create a new token bucket.
  ##
  ## - capacity: Maximum number of tokens the bucket can hold
  ## - refillRate: Number of tokens added per second
  assert capacity > 0, "Capacity must be positive"
  assert refillRate > 0, "Refill rate must be positive"
  
  result = TokenBucket(
    capacity: capacity,
    refillRate: refillRate,
    tokens: capacity,  # Start full
    lastRefill: getMonoTime()
  )
  initLock(result.lock)

proc refill(bucket: TokenBucket) =
  ## Add tokens based on elapsed time since last refill.
  let now = getMonoTime()
  let elapsed = now - bucket.lastRefill
  
  if elapsed > 0:
    let tokensToAdd = elapsed * bucket.refillRate
    bucket.tokens = min(bucket.capacity, bucket.tokens + tokensToAdd)
    bucket.lastRefill = now

proc consume*(bucket: TokenBucket, tokens: float = 1.0): bool =
  ## Attempt to consume tokens from the bucket.
  ##
  ## Returns true if tokens were consumed, false if insufficient.
  withLock bucket.lock:
    bucket.refill()
    
    if bucket.tokens >= tokens:
      bucket.tokens -= tokens
      return true
    return false

proc available*(bucket: TokenBucket): float =
  ## Get the current number of available tokens.
  withLock bucket.lock:
    bucket.refill()
    return bucket.tokens

# --- Demonstration ---

when isMainModule:
  import std/os
  
  echo "Token Bucket Rate Limiter - Nim Implementation"
  echo "=".repeat(50)
  echo ""
  
  # Create a bucket: 5 tokens capacity, 2 tokens/second refill
  let limiter = newTokenBucket(5, 2)
  
  echo &"Created limiter: capacity={limiter.capacity:.0f}, refill_rate={limiter.refillRate:.0f}/s"
  echo &"Starting tokens: {limiter.available:.0f}"
  echo ""
  
  # Consume all tokens rapidly
  echo "--- Rapid consumption ---"
  for i in 1..7:
    let result = limiter.consume()
    let status = if result: "✓ allowed" else: "✗ denied"
    echo &"  Attempt {i}: {status} (tokens left: {limiter.available:.2f})"
  echo ""
  
  # Wait for refill
  echo "--- Waiting 1 second for refill ---"
  sleep(1000)
  echo &"Tokens after 1s: {limiter.available:.2f}"
  echo ""
  
  # Try again
  echo "--- Post-refill consumption ---"
  for i in 1..3:
    let result = limiter.consume()
    let status = if result: "✓ allowed" else: "✗ denied"
    echo &"  Attempt {i}: {status} (tokens left: {limiter.available:.2f})"
  echo ""
  
  echo "=".repeat(50)
  echo "Human intent → Nim implementation ✓"
