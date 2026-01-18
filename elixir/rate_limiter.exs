# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.

defmodule TokenBucket do
  @moduledoc """
  A rate limiter using the token bucket algorithm.

  Tokens refill at a steady rate up to a maximum capacity.
  Each action consumes one token. If no tokens are available,
  the action is denied.
  """

  use Agent

  defstruct [:capacity, :refill_rate, :tokens, :last_refill]

  @doc """
  Create a new token bucket rate limiter.

  - capacity: Maximum number of tokens the bucket can hold
  - refill_rate: Number of tokens added per second
  """
  def start_link(capacity, refill_rate) when capacity > 0 and refill_rate > 0 do
    Agent.start_link(fn ->
      %__MODULE__{
        capacity: capacity / 1,  # Ensure float
        refill_rate: refill_rate / 1,
        tokens: capacity / 1,  # Start full
        last_refill: System.monotonic_time(:millisecond)
      }
    end)
  end

  defp refill(state) do
    now = System.monotonic_time(:millisecond)
    elapsed_ms = now - state.last_refill

    if elapsed_ms > 0 do
      elapsed_sec = elapsed_ms / 1000
      tokens_to_add = elapsed_sec * state.refill_rate
      new_tokens = min(state.capacity, state.tokens + tokens_to_add)
      %{state | tokens: new_tokens, last_refill: now}
    else
      state
    end
  end

  @doc """
  Attempt to consume tokens from the bucket.
  Returns true if tokens were consumed, false if insufficient.
  """
  def consume(bucket, tokens \\ 1.0) do
    Agent.get_and_update(bucket, fn state ->
      refilled = refill(state)
      if refilled.tokens >= tokens do
        {true, %{refilled | tokens: refilled.tokens - tokens}}
      else
        {false, refilled}
      end
    end)
  end

  @doc """
  Get the current number of available tokens.
  """
  def available(bucket) do
    Agent.get(bucket, fn state ->
      refill(state).tokens
    end)
  end

  def capacity(bucket), do: Agent.get(bucket, & &1.capacity)
  def refill_rate(bucket), do: Agent.get(bucket, & &1.refill_rate)
end

# --- Demonstration ---

IO.puts("Token Bucket Rate Limiter - Elixir Implementation")
IO.puts(String.duplicate("=", 50))

{:ok, limiter} = TokenBucket.start_link(5, 2)

IO.puts("")
IO.puts("Created limiter: capacity=#{trunc(TokenBucket.capacity(limiter))}, refill_rate=#{trunc(TokenBucket.refill_rate(limiter))}/s")
IO.puts("Starting tokens: #{trunc(TokenBucket.available(limiter))}")

IO.puts("")
IO.puts("--- Rapid consumption ---")
for i <- 1..7 do
  result = TokenBucket.consume(limiter)
  status = if result, do: "✓ allowed", else: "✗ denied"
  tokens = :erlang.float_to_binary(TokenBucket.available(limiter), decimals: 2)
  IO.puts("  Attempt #{i}: #{status} (tokens left: #{tokens})")
end

IO.puts("")
IO.puts("--- Waiting 1 second for refill ---")
:timer.sleep(1000)
tokens = :erlang.float_to_binary(TokenBucket.available(limiter), decimals: 2)
IO.puts("Tokens after 1s: #{tokens}")

IO.puts("")
IO.puts("--- Post-refill consumption ---")
for i <- 1..3 do
  result = TokenBucket.consume(limiter)
  status = if result, do: "✓ allowed", else: "✗ denied"
  tokens = :erlang.float_to_binary(TokenBucket.available(limiter), decimals: 2)
  IO.puts("  Attempt #{i}: #{status} (tokens left: #{tokens})")
end

IO.puts("")
IO.puts(String.duplicate("=", 50))
IO.puts("Human intent → Elixir implementation ✓")
