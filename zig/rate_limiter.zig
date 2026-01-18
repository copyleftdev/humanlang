//! Token Bucket Rate Limiter
//!
//! Transpiled from INTENT.md - Human language is the source code.

const std = @import("std");
const time = std.time;
const Thread = std.Thread;
const Mutex = Thread.Mutex;

/// A rate limiter using the token bucket algorithm.
///
/// Tokens refill at a steady rate up to a maximum capacity.
/// Each action consumes one token. If no tokens are available,
/// the action is denied.
pub const TokenBucket = struct {
    capacity: f64,
    refill_rate: f64,
    tokens: f64,
    last_refill: i128,
    mutex: Mutex,

    const Self = @This();

    /// Create a new token bucket.
    pub fn init(capacity: f64, refill_rate: f64) Self {
        std.debug.assert(capacity > 0);
        std.debug.assert(refill_rate > 0);

        return Self{
            .capacity = capacity,
            .refill_rate = refill_rate,
            .tokens = capacity, // Start full
            .last_refill = time.nanoTimestamp(),
            .mutex = Mutex{},
        };
    }

    /// Add tokens based on elapsed time since last refill.
    fn refill(self: *Self) void {
        const now = time.nanoTimestamp();
        const elapsed_ns = now - self.last_refill;

        if (elapsed_ns > 0) {
            const elapsed_secs = @as(f64, @floatFromInt(elapsed_ns)) / 1e9;
            const tokens_to_add = elapsed_secs * self.refill_rate;
            self.tokens = @min(self.capacity, self.tokens + tokens_to_add);
            self.last_refill = now;
        }
    }

    /// Attempt to consume tokens from the bucket.
    pub fn consume(self: *Self, tokens: f64) bool {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.refill();

        if (self.tokens >= tokens) {
            self.tokens -= tokens;
            return true;
        }
        return false;
    }

    /// Consume a single token.
    pub fn consumeOne(self: *Self) bool {
        return self.consume(1.0);
    }

    /// Get the current number of available tokens.
    pub fn available(self: *Self) f64 {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.refill();
        return self.tokens;
    }
};

// --- Demonstration ---

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Token Bucket Rate Limiter - Zig Implementation\n", .{});
    try stdout.print("==================================================\n", .{});

    // Create a bucket: 5 tokens capacity, 2 tokens/second refill
    var limiter = TokenBucket.init(5.0, 2.0);

    try stdout.print("\nCreated limiter: capacity={d:.0}, refill_rate={d:.0}/s\n", .{ limiter.capacity, limiter.refill_rate });
    try stdout.print("Starting tokens: {d:.0}\n", .{limiter.available()});

    // Consume all tokens rapidly
    try stdout.print("\n--- Rapid consumption ---\n", .{});
    for (0..7) |i| {
        const result = limiter.consumeOne();
        const status = if (result) "allowed" else "denied";
        try stdout.print("  Attempt {d}: {s} (tokens left: {d:.2})\n", .{ i + 1, status, limiter.available() });
    }

    // Wait for refill
    try stdout.print("\n--- Waiting 1 second for refill ---\n", .{});
    std.time.sleep(1 * std.time.ns_per_s);
    try stdout.print("Tokens after 1s: {d:.2}\n", .{limiter.available()});

    // Try again
    try stdout.print("\n--- Post-refill consumption ---\n", .{});
    for (0..3) |i| {
        const result = limiter.consumeOne();
        const status = if (result) "allowed" else "denied";
        try stdout.print("  Attempt {d}: {s} (tokens left: {d:.2})\n", .{ i + 1, status, limiter.available() });
    }

    try stdout.print("\n==================================================\n", .{});
    try stdout.print("Human intent -> Zig implementation\n", .{});
}
