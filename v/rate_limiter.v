// Token Bucket Rate Limiter
// Transpiled from INTENT.md - Human language is the source code.
// V: The simple, fast language. Like Go met C and had a baby.

import time
import sync

struct TokenBucket {
mut:
	capacity    f64
	refill_rate f64
	tokens      f64
	last_refill i64
	mtx         sync.Mutex
}

fn new_token_bucket(capacity f64, refill_rate f64) &TokenBucket {
	assert capacity > 0, 'Capacity must be positive'
	assert refill_rate > 0, 'Refill rate must be positive'

	return &TokenBucket{
		capacity: capacity
		refill_rate: refill_rate
		tokens: capacity
		last_refill: time.now().unix_nano()
	}
}

fn (mut tb TokenBucket) refill() {
	now := time.now().unix_nano()
	elapsed_ns := now - tb.last_refill

	if elapsed_ns > 0 {
		elapsed_sec := f64(elapsed_ns) / 1e9
		tokens_to_add := elapsed_sec * tb.refill_rate
		tb.tokens = if tb.tokens + tokens_to_add > tb.capacity {
			tb.capacity
		} else {
			tb.tokens + tokens_to_add
		}
		tb.last_refill = now
	}
}

fn (mut tb TokenBucket) consume(tokens f64) bool {
	tb.mtx.@lock()
	defer { tb.mtx.unlock() }

	tb.refill()

	if tb.tokens >= tokens {
		tb.tokens -= tokens
		return true
	}
	return false
}

fn (mut tb TokenBucket) available() f64 {
	tb.mtx.@lock()
	defer { tb.mtx.unlock() }

	tb.refill()
	return tb.tokens
}

fn main() {
	println('Token Bucket Rate Limiter - V Implementation')
	println('${'='.repeat(50)}')
	println('')

	mut limiter := new_token_bucket(5, 2)

	println('Created limiter: capacity=${limiter.capacity:.0}, refill_rate=${limiter.refill_rate:.0}/s')
	println('Starting tokens: ${limiter.available():.0}')
	println('')

	println('--- Rapid consumption ---')
	for i in 1 .. 8 {
		result := limiter.consume(1.0)
		status := if result { '✓ allowed' } else { '✗ denied' }
		println('  Attempt ${i}: ${status} (tokens left: ${limiter.available():.2})')
	}
	println('')

	println('--- Waiting 1 second for refill ---')
	time.sleep(1 * time.second)
	println('Tokens after 1s: ${limiter.available():.2}')
	println('')

	println('--- Post-refill consumption ---')
	for i in 1 .. 4 {
		result := limiter.consume(1.0)
		status := if result { '✓ allowed' } else { '✗ denied' }
		println('  Attempt ${i}: ${status} (tokens left: ${limiter.available():.2})')
	}
	println('')

	println('${'='.repeat(50)}')
	println('Human intent → V implementation ✓')
}
