# Intent: Token Bucket Rate Limiter

## The Idea (Plain English)

I want to control how fast actions can happen—like a bouncer at a club who only lets people in at a certain pace.

Here's how it works:

**Imagine a bucket that holds tokens.**

- The bucket has a maximum capacity (let's say 10 tokens)
- Tokens refill into the bucket at a steady rate (let's say 1 token per second)
- The bucket never overflows—if it's full, new tokens are discarded
- When someone wants to perform an action, they must take a token from the bucket
- If there's a token available, they take it and proceed immediately
- If the bucket is empty, they're denied (or must wait)

This simple mechanism elegantly solves:
- API rate limiting ("max 100 requests per minute")
- Network traffic shaping
- Resource protection
- Burst handling (the bucket allows short bursts up to capacity)

---

## The Contract

### Create a Rate Limiter

```
Create a rate limiter with:
  - capacity: maximum number of tokens the bucket can hold
  - refill_rate: how many tokens are added per second
```

### Attempt to Consume

```
When someone tries to consume a token:
  - First, calculate how many tokens should have been added since last check
  - Add those tokens (but don't exceed capacity)
  - If at least 1 token is available:
      - Remove 1 token
      - Return success (true)
  - If no tokens available:
      - Return failure (false)
```

### Check Available Tokens

```
Return how many tokens are currently available (after refilling)
```

---

## Behavior Examples

```
Create limiter with capacity=5, refill_rate=2 tokens/second

At time 0.0s:
  - Bucket starts full (5 tokens)
  - consume() → true (4 tokens left)
  - consume() → true (3 tokens left)
  - consume() → true (2 tokens left)
  - consume() → true (1 token left)
  - consume() → true (0 tokens left)
  - consume() → false (empty!)

At time 0.5s:
  - 1 token has refilled (0.5s × 2/s = 1)
  - consume() → true (0 tokens left)
  - consume() → false (empty!)

At time 5.0s:
  - 10 tokens would have refilled, but capped at capacity
  - available() → 5
```

---

## Edge Cases to Handle

1. **Time going backwards**: If system clock adjusts, don't generate negative tokens
2. **Very long gaps**: Don't exceed capacity no matter how much time passes
3. **Fractional tokens**: Track partial tokens internally for precision
4. **Concurrent access**: In multi-threaded contexts, handle safely (language-dependent)

---

## What This Is NOT

- This is NOT a queue (we don't make people wait in line)
- This is NOT a simple counter reset (that would allow bursts at boundaries)
- This is NOT per-user/per-key limiting (this is a single bucket)

---

## Implementation Notes

Each language should:
1. Be idiomatic to that language's conventions
2. Include a simple demonstration/test
3. Handle the edge cases appropriately
4. Be production-quality, not a toy

---

*This intent document is the source of truth. All implementations derive from this description, not from each other.*
