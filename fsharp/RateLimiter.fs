// Token Bucket Rate Limiter
//
// Transpiled from INTENT.md - Human language is the source code.

module RateLimiter

open System
open System.Diagnostics

/// A rate limiter using the token bucket algorithm.
///
/// Tokens refill at a steady rate up to a maximum capacity.
/// Each action consumes one token. If no tokens are available,
/// the action is denied.
type TokenBucket(capacity: float, refillRate: float) =
    do
        if capacity <= 0.0 then invalidArg "capacity" "Capacity must be positive"
        if refillRate <= 0.0 then invalidArg "refillRate" "Refill rate must be positive"

    let stopwatch = Stopwatch.StartNew()
    let mutable tokens = capacity  // Start full
    let mutable lastRefill = stopwatch.Elapsed.TotalSeconds
    let lockObj = obj()

    let refill () =
        let now = stopwatch.Elapsed.TotalSeconds
        let elapsed = now - lastRefill
        if elapsed > 0.0 then
            let tokensToAdd = elapsed * refillRate
            tokens <- min capacity (tokens + tokensToAdd)
            lastRefill <- now

    member _.Capacity = capacity
    member _.RefillRate = refillRate

    /// Attempt to consume tokens from the bucket.
    member _.Consume(?tokenCount: float) =
        let n = defaultArg tokenCount 1.0
        lock lockObj (fun () ->
            refill()
            if tokens >= n then
                tokens <- tokens - n
                true
            else
                false)

    /// Get the current number of available tokens.
    member _.Available =
        lock lockObj (fun () ->
            refill()
            tokens)

// --- Demonstration ---

let demo () =
    printfn "Token Bucket Rate Limiter - F# Implementation"
    printfn "%s" (String.replicate 50 "=")
    printfn ""

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    let limiter = TokenBucket(5.0, 2.0)

    printfn "Created limiter: capacity=%.0f, refill_rate=%.0f/s" limiter.Capacity limiter.RefillRate
    printfn "Starting tokens: %.0f" limiter.Available
    printfn ""

    // Consume all tokens rapidly
    printfn "--- Rapid consumption ---"
    for i in 1..7 do
        let result = limiter.Consume()
        let status = if result then "✓ allowed" else "✗ denied"
        printfn "  Attempt %d: %s (tokens left: %.2f)" i status limiter.Available
    printfn ""

    // Wait for refill
    printfn "--- Waiting 1 second for refill ---"
    Threading.Thread.Sleep(1000)
    printfn "Tokens after 1s: %.2f" limiter.Available
    printfn ""

    // Try again
    printfn "--- Post-refill consumption ---"
    for i in 1..3 do
        let result = limiter.Consume()
        let status = if result then "✓ allowed" else "✗ denied"
        printfn "  Attempt %d: %s (tokens left: %.2f)" i status limiter.Available
    printfn ""

    printfn "%s" (String.replicate 50 "=")
    printfn "Human intent → F# implementation ✓"

// Run the demo
demo ()
