{-|
Module      : RateLimiter
Description : Token Bucket Rate Limiter
License     : MIT

Transpiled from INTENT.md - Human language is the source code.
-}

module Main where

import Control.Concurrent (threadDelay)
import Control.Concurrent.MVar
import Data.Time.Clock (UTCTime, getCurrentTime, diffUTCTime)
import Text.Printf (printf)

-- | Internal state of the token bucket
data BucketState = BucketState
  { bsTokens     :: !Double
  , bsLastRefill :: !UTCTime
  } deriving (Show)

-- | A rate limiter using the token bucket algorithm.
--
-- Tokens refill at a steady rate up to a maximum capacity.
-- Each action consumes one token. If no tokens are available,
-- the action is denied.
data TokenBucket = TokenBucket
  { tbCapacity   :: !Double
  , tbRefillRate :: !Double
  , tbState      :: MVar BucketState
  }

-- | Create a new token bucket.
--
-- @capacity@: Maximum number of tokens the bucket can hold
-- @refillRate@: Number of tokens added per second
newTokenBucket :: Double -> Double -> IO TokenBucket
newTokenBucket capacity refillRate
  | capacity <= 0   = error "Capacity must be positive"
  | refillRate <= 0 = error "Refill rate must be positive"
  | otherwise = do
      now <- getCurrentTime
      state <- newMVar BucketState
        { bsTokens = capacity  -- Start full
        , bsLastRefill = now
        }
      return TokenBucket
        { tbCapacity = capacity
        , tbRefillRate = refillRate
        , tbState = state
        }

-- | Add tokens based on elapsed time since last refill.
refill :: TokenBucket -> BucketState -> IO BucketState
refill bucket state = do
  now <- getCurrentTime
  let elapsed = realToFrac (diffUTCTime now (bsLastRefill state)) :: Double
  if elapsed > 0
    then do
      let tokensToAdd = elapsed * tbRefillRate bucket
          newTokens = min (tbCapacity bucket) (bsTokens state + tokensToAdd)
      return state { bsTokens = newTokens, bsLastRefill = now }
    else return state

-- | Attempt to consume tokens from the bucket.
--
-- Returns 'True' if tokens were consumed, 'False' if insufficient tokens.
consume :: TokenBucket -> Double -> IO Bool
consume bucket tokens = modifyMVar (tbState bucket) $ \state -> do
  refilled <- refill bucket state
  if bsTokens refilled >= tokens
    then return (refilled { bsTokens = bsTokens refilled - tokens }, True)
    else return (refilled, False)

-- | Consume a single token.
consumeOne :: TokenBucket -> IO Bool
consumeOne bucket = consume bucket 1.0

-- | Get the current number of available tokens.
available :: TokenBucket -> IO Double
available bucket = modifyMVar (tbState bucket) $ \state -> do
  refilled <- refill bucket state
  return (refilled, bsTokens refilled)

-- | Get the capacity of the bucket.
capacity :: TokenBucket -> Double
capacity = tbCapacity

-- | Get the refill rate of the bucket.
refillRate :: TokenBucket -> Double
refillRate = tbRefillRate

-- --- Demonstration ---

main :: IO ()
main = do
  putStrLn "Token Bucket Rate Limiter - Haskell Implementation"
  putStrLn $ replicate 50 '='
  
  -- Create a bucket: 5 tokens capacity, 2 tokens/second refill
  limiter <- newTokenBucket 5 2
  
  printf "\nCreated limiter: capacity=%.0f, refill_rate=%.0f/s\n"
         (capacity limiter) (refillRate limiter)
  startTokens <- available limiter
  printf "Starting tokens: %.0f\n" startTokens
  
  -- Consume all tokens rapidly
  putStrLn "\n--- Rapid consumption ---"
  mapM_ (attemptConsume limiter) [1..7]
  
  -- Wait for refill
  putStrLn "\n--- Waiting 1 second for refill ---"
  threadDelay 1000000  -- 1 second in microseconds
  tokensAfter <- available limiter
  printf "Tokens after 1s: %.2f\n" tokensAfter
  
  -- Try again
  putStrLn "\n--- Post-refill consumption ---"
  mapM_ (attemptConsume limiter) [1..3]
  
  putStrLn ""
  putStrLn $ replicate 50 '='
  putStrLn "Human intent → Haskell implementation ✓"

attemptConsume :: TokenBucket -> Int -> IO ()
attemptConsume limiter i = do
  result <- consumeOne limiter
  tokens <- available limiter
  let status = if result then "✓ allowed" else "✗ denied"
  printf "  Attempt %d: %s (tokens left: %.2f)\n" i status tokens
