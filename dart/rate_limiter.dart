// Token Bucket Rate Limiter
//
// Transpiled from INTENT.md - Human language is the source code.

/// A rate limiter using the token bucket algorithm.
///
/// Tokens refill at a steady rate up to a maximum capacity.
/// Each action consumes one token. If no tokens are available,
/// the action is denied.
class TokenBucket {
  final double capacity;
  final double refillRate;
  double _tokens;
  int _lastRefill;

  /// Create a new token bucket.
  ///
  /// - [capacity]: Maximum number of tokens the bucket can hold
  /// - [refillRate]: Number of tokens added per second
  TokenBucket(this.capacity, this.refillRate)
      : assert(capacity > 0, 'Capacity must be positive'),
        assert(refillRate > 0, 'Refill rate must be positive'),
        _tokens = capacity, // Start full
        _lastRefill = DateTime.now().microsecondsSinceEpoch;

  /// Add tokens based on elapsed time since last refill.
  void _refill() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final elapsedUs = now - _lastRefill;

    if (elapsedUs > 0) {
      final elapsedSec = elapsedUs / 1e6;
      final tokensToAdd = elapsedSec * refillRate;
      _tokens = (_tokens + tokensToAdd).clamp(0, capacity);
      _lastRefill = now;
    }
  }

  /// Attempt to consume tokens from the bucket.
  ///
  /// Returns true if tokens were consumed, false if insufficient.
  bool consume([double tokens = 1.0]) {
    _refill();

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }
    return false;
  }

  /// Get the current number of available tokens.
  double get available {
    _refill();
    return _tokens;
  }
}

// --- Demonstration ---

Future<void> main() async {
  print('Token Bucket Rate Limiter - Dart Implementation');
  print('=' * 50);
  print('');

  // Create a bucket: 5 tokens capacity, 2 tokens/second refill
  final limiter = TokenBucket(5, 2);

  print('Created limiter: capacity=${limiter.capacity.toInt()}, refill_rate=${limiter.refillRate.toInt()}/s');
  print('Starting tokens: ${limiter.available.toInt()}');
  print('');

  // Consume all tokens rapidly
  print('--- Rapid consumption ---');
  for (var i = 1; i <= 7; i++) {
    final result = limiter.consume();
    final status = result ? '✓ allowed' : '✗ denied';
    print('  Attempt $i: $status (tokens left: ${limiter.available.toStringAsFixed(2)})');
  }
  print('');

  // Wait for refill
  print('--- Waiting 1 second for refill ---');
  await Future.delayed(Duration(seconds: 1));
  print('Tokens after 1s: ${limiter.available.toStringAsFixed(2)}');
  print('');

  // Try again
  print('--- Post-refill consumption ---');
  for (var i = 1; i <= 3; i++) {
    final result = limiter.consume();
    final status = result ? '✓ allowed' : '✗ denied';
    print('  Attempt $i: $status (tokens left: ${limiter.available.toStringAsFixed(2)})');
  }
  print('');

  print('=' * 50);
  print('Human intent → Dart implementation ✓');
}
