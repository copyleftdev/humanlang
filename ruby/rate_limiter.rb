# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.

require 'monitor'

# A rate limiter using the token bucket algorithm.
#
# Tokens refill at a steady rate up to a maximum capacity.
# Each action consumes one token. If no tokens are available,
# the action is denied.
class TokenBucket
  attr_reader :capacity, :refill_rate

  # Create a new token bucket.
  #
  # @param capacity [Numeric] Maximum number of tokens the bucket can hold
  # @param refill_rate [Numeric] Number of tokens added per second
  def initialize(capacity, refill_rate)
    raise ArgumentError, 'Capacity must be positive' unless capacity.positive?
    raise ArgumentError, 'Refill rate must be positive' unless refill_rate.positive?

    @capacity = capacity.to_f
    @refill_rate = refill_rate.to_f
    @tokens = @capacity  # Start full
    @last_refill = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @monitor = Monitor.new
  end

  # Attempt to consume tokens from the bucket.
  #
  # @param tokens [Numeric] Number of tokens to consume (default: 1)
  # @return [Boolean] true if tokens were consumed, false if insufficient
  def consume(tokens = 1)
    @monitor.synchronize do
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
  #
  # @return [Float] Number of tokens currently in the bucket
  def available
    @monitor.synchronize do
      refill
      @tokens
    end
  end

  private

  def refill
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = now - @last_refill

    if elapsed.positive?
      tokens_to_add = elapsed * @refill_rate
      @tokens = [@capacity, @tokens + tokens_to_add].min
      @last_refill = now
    end
  end
end

# --- Demonstration ---

if __FILE__ == $PROGRAM_NAME
  puts 'Token Bucket Rate Limiter - Ruby Implementation'
  puts '=' * 50

  # Create a bucket: 5 tokens capacity, 2 tokens/second refill
  limiter = TokenBucket.new(5, 2)

  puts
  puts "Created limiter: capacity=#{limiter.capacity.to_i}, refill_rate=#{limiter.refill_rate.to_i}/s"
  puts "Starting tokens: #{limiter.available.to_i}"

  # Consume all tokens rapidly
  puts
  puts '--- Rapid consumption ---'
  7.times do |i|
    result = limiter.consume
    status = result ? '✓ allowed' : '✗ denied'
    puts "  Attempt #{i + 1}: #{status} (tokens left: #{'%.2f' % limiter.available})"
  end

  # Wait for refill
  puts
  puts '--- Waiting 1 second for refill ---'
  sleep(1)
  puts "Tokens after 1s: #{'%.2f' % limiter.available}"

  # Try again
  puts
  puts '--- Post-refill consumption ---'
  3.times do |i|
    result = limiter.consume
    status = result ? '✓ allowed' : '✗ denied'
    puts "  Attempt #{i + 1}: #{status} (tokens left: #{'%.2f' % limiter.available})"
  end

  puts
  puts '=' * 50
  puts 'Human intent → Ruby implementation ✓'
end
