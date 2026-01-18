-- Token Bucket Rate Limiter
--
-- Transpiled from INTENT.md - Human language is the source code.

local socket = pcall(require, "socket") and require("socket") or nil

--- Get current time in seconds (with subsecond precision if available)
local function get_time()
    if socket then
        return socket.gettime()
    else
        return os.time()
    end
end

--- A rate limiter using the token bucket algorithm.
-- Tokens refill at a steady rate up to a maximum capacity.
-- Each action consumes one token. If no tokens are available,
-- the action is denied.
local TokenBucket = {}
TokenBucket.__index = TokenBucket

--- Create a new token bucket.
-- @param capacity number Maximum number of tokens the bucket can hold
-- @param refill_rate number Number of tokens added per second
-- @return TokenBucket
function TokenBucket.new(capacity, refill_rate)
    assert(capacity > 0, "Capacity must be positive")
    assert(refill_rate > 0, "Refill rate must be positive")

    local self = setmetatable({}, TokenBucket)
    self.capacity = capacity
    self.refill_rate = refill_rate
    self.tokens = capacity  -- Start full
    self.last_refill = get_time()
    return self
end

--- Add tokens based on elapsed time since last refill.
function TokenBucket:_refill()
    local now = get_time()
    local elapsed = now - self.last_refill

    if elapsed > 0 then
        local tokens_to_add = elapsed * self.refill_rate
        self.tokens = math.min(self.capacity, self.tokens + tokens_to_add)
        self.last_refill = now
    end
end

--- Attempt to consume tokens from the bucket.
-- @param tokens number Number of tokens to consume (default: 1)
-- @return boolean true if tokens were consumed, false if insufficient
function TokenBucket:consume(tokens)
    tokens = tokens or 1

    self:_refill()

    if self.tokens >= tokens then
        self.tokens = self.tokens - tokens
        return true
    end
    return false
end

--- Get the current number of available tokens.
-- @return number
function TokenBucket:available()
    self:_refill()
    return self.tokens
end

-- --- Demonstration ---

local function sleep(seconds)
    if socket then
        socket.sleep(seconds)
    else
        local start = os.time()
        while os.time() - start < seconds do end
    end
end

local function main()
    print("Token Bucket Rate Limiter - Lua Implementation")
    print(string.rep("=", 50))

    -- Create a bucket: 5 tokens capacity, 2 tokens/second refill
    local limiter = TokenBucket.new(5, 2)

    print()
    print(string.format("Created limiter: capacity=%d, refill_rate=%d/s",
          limiter.capacity, limiter.refill_rate))
    print(string.format("Starting tokens: %d", limiter:available()))

    -- Consume all tokens rapidly
    print()
    print("--- Rapid consumption ---")
    for i = 1, 7 do
        local result = limiter:consume()
        local status = result and "✓ allowed" or "✗ denied"
        print(string.format("  Attempt %d: %s (tokens left: %.2f)",
              i, status, limiter:available()))
    end

    -- Wait for refill
    print()
    print("--- Waiting 1 second for refill ---")
    sleep(1)
    print(string.format("Tokens after 1s: %.2f", limiter:available()))

    -- Try again
    print()
    print("--- Post-refill consumption ---")
    for i = 1, 3 do
        local result = limiter:consume()
        local status = result and "✓ allowed" or "✗ denied"
        print(string.format("  Attempt %d: %s (tokens left: %.2f)",
              i, status, limiter:available()))
    end

    print()
    print(string.rep("=", 50))
    print("Human intent → Lua implementation ✓")
end

main()

return TokenBucket
