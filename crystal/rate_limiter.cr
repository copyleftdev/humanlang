# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.

# A rate limiter using the token bucket algorithm.
#
# Tokens refill at a steady rate up to a maximum capacity.
# Each action consumes one token. If no tokens are available,
# the action is denied.
class TokenBucket
  getter capacity : Float64
  getter refill_rate : Float64

  # Create a new token bucket.
  #
  # - capacity: Maximum number of tokens the bucket can hold
  # - refill_rate: Number of tokens added per second
  def initialize(@capacity : Float64, @refill_rate : Float64)
    raise ArgumentError.new("Capacity must be positive") unless @capacity > 0
    raise ArgumentError.new("Refill rate must be positive") unless @refill_rate > 0

    @tokens = @capacity  # Start full
    @last_refill = Time.monotonic
    @mutex = Mutex.new
  end

  # Add tokens based on elapsed time since last refill.
  private def refill
    now = Time.monotonic
    elapsed = (now - @last_refill).total_seconds

    if elapsed > 0
      tokens_to_add = elapsed * @refill_rate
      @tokens = Math.min(@capacity, @tokens + tokens_to_add)
      @last_refill = now
    end
  end

  # Attempt to consume tokens from the bucket.
  #
  # Returns true if tokens were consumed, false if insufficient.
  def consume(tokens : Float64 = 1.0) : Bool
    @mutex.synchronize do
      refill

      if @tokens >= tokens
        @tokens -= tokens
        true
      else
        false
      end
    end
  end

  # Get the current number of available tokens.
  def available : Float64
    @mutex.synchronize do
      refill
      @tokens
    end
  end
end

# --- Demonstration ---

puts "Token Bucket Rate Limiter - Crystal Implementation"
puts "=" * 50
puts

# Create a bucket: 5 tokens capacity, 2 tokens/second refill
limiter = TokenBucket.new(5.0, 2.0)

puts "Created limiter: capacity=#{limiter.capacity.to_i}, refill_rate=#{limiter.refill_rate.to_i}/s"
puts "Starting tokens: #{limiter.available.to_i}"
puts

# Consume all tokens rapidly
puts "--- Rapid consumption ---"
7.times do |i|
  result = limiter.consume
  status = result ? "✓ allowed" : "✗ denied"
  puts "  Attempt #{i + 1}: #{status} (tokens left: #{"%.2f" % limiter.available})"
end
puts

# Wait for refill
puts "--- Waiting 1 second for refill ---"
sleep(1)
puts "Tokens after 1s: #{"%.2f" % limiter.available}"
puts

# Try again
puts "--- Post-refill consumption ---"
3.times do |i|
  result = limiter.consume
  status = result ? "✓ allowed" : "✗ denied"
  puts "  Attempt #{i + 1}: #{status} (tokens left: #{"%.2f" % limiter.available})"
end
puts

puts "=" * 50
puts "Human intent → Crystal implementation ✓"
