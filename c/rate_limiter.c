/**
 * Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 */

#define _POSIX_C_SOURCE 199309L

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>

/**
 * A rate limiter using the token bucket algorithm.
 *
 * Tokens refill at a steady rate up to a maximum capacity.
 * Each action consumes one token. If no tokens are available,
 * the action is denied.
 */
typedef struct {
    double capacity;
    double refill_rate;
    double tokens;
    struct timespec last_refill;
    pthread_mutex_t lock;
} TokenBucket;

/**
 * Get current monotonic time in seconds.
 */
static double get_time_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

/**
 * Add tokens based on elapsed time since last refill.
 * Must be called with lock held.
 */
static void refill(TokenBucket *bucket) {
    double now = get_time_seconds();
    double last = bucket->last_refill.tv_sec + bucket->last_refill.tv_nsec / 1e9;
    double elapsed = now - last;

    /* Guard against clock issues */
    if (elapsed > 0) {
        double tokens_to_add = elapsed * bucket->refill_rate;
        bucket->tokens += tokens_to_add;
        if (bucket->tokens > bucket->capacity) {
            bucket->tokens = bucket->capacity;
        }
        clock_gettime(CLOCK_MONOTONIC, &bucket->last_refill);
    }
}

/**
 * Create a new token bucket.
 *
 * @param capacity Maximum number of tokens the bucket can hold
 * @param refill_rate Number of tokens added per second
 * @return Pointer to new TokenBucket, or NULL on failure
 */
TokenBucket *token_bucket_new(double capacity, double refill_rate) {
    if (capacity <= 0 || refill_rate <= 0) {
        fprintf(stderr, "Error: capacity and refill_rate must be positive\n");
        return NULL;
    }

    TokenBucket *bucket = malloc(sizeof(TokenBucket));
    if (!bucket) {
        return NULL;
    }

    bucket->capacity = capacity;
    bucket->refill_rate = refill_rate;
    bucket->tokens = capacity;  /* Start full */
    clock_gettime(CLOCK_MONOTONIC, &bucket->last_refill);
    pthread_mutex_init(&bucket->lock, NULL);

    return bucket;
}

/**
 * Destroy a token bucket and free resources.
 */
void token_bucket_destroy(TokenBucket *bucket) {
    if (bucket) {
        pthread_mutex_destroy(&bucket->lock);
        free(bucket);
    }
}

/**
 * Attempt to consume tokens from the bucket.
 *
 * @param bucket The token bucket
 * @param tokens Number of tokens to consume
 * @return true if tokens were consumed, false if insufficient tokens
 */
bool token_bucket_consume(TokenBucket *bucket, double tokens) {
    pthread_mutex_lock(&bucket->lock);
    refill(bucket);

    bool success = false;
    if (bucket->tokens >= tokens) {
        bucket->tokens -= tokens;
        success = true;
    }

    pthread_mutex_unlock(&bucket->lock);
    return success;
}

/**
 * Consume a single token.
 */
bool token_bucket_consume_one(TokenBucket *bucket) {
    return token_bucket_consume(bucket, 1.0);
}

/**
 * Get the current number of available tokens.
 */
double token_bucket_available(TokenBucket *bucket) {
    pthread_mutex_lock(&bucket->lock);
    refill(bucket);
    double available = bucket->tokens;
    pthread_mutex_unlock(&bucket->lock);
    return available;
}

/**
 * Get the capacity of the bucket.
 */
double token_bucket_capacity(TokenBucket *bucket) {
    return bucket->capacity;
}

/**
 * Get the refill rate of the bucket.
 */
double token_bucket_refill_rate(TokenBucket *bucket) {
    return bucket->refill_rate;
}

/* --- Demonstration --- */

int main(void) {
    printf("Token Bucket Rate Limiter - C Implementation\n");
    for (int i = 0; i < 50; i++) printf("=");
    printf("\n");

    /* Create a bucket: 5 tokens capacity, 2 tokens/second refill */
    TokenBucket *limiter = token_bucket_new(5, 2);
    if (!limiter) {
        fprintf(stderr, "Failed to create token bucket\n");
        return 1;
    }

    printf("\nCreated limiter: capacity=%.0f, refill_rate=%.0f/s\n",
           token_bucket_capacity(limiter), token_bucket_refill_rate(limiter));
    printf("Starting tokens: %.0f\n", token_bucket_available(limiter));

    /* Consume all tokens rapidly */
    printf("\n--- Rapid consumption ---\n");
    for (int i = 0; i < 7; i++) {
        bool result = token_bucket_consume_one(limiter);
        printf("  Attempt %d: %s (tokens left: %.2f)\n",
               i + 1,
               result ? "✓ allowed" : "✗ denied",
               token_bucket_available(limiter));
    }

    /* Wait for refill */
    printf("\n--- Waiting 1 second for refill ---\n");
    sleep(1);
    printf("Tokens after 1s: %.2f\n", token_bucket_available(limiter));

    /* Try again */
    printf("\n--- Post-refill consumption ---\n");
    for (int i = 0; i < 3; i++) {
        bool result = token_bucket_consume_one(limiter);
        printf("  Attempt %d: %s (tokens left: %.2f)\n",
               i + 1,
               result ? "✓ allowed" : "✗ denied",
               token_bucket_available(limiter));
    }

    printf("\n");
    for (int i = 0; i < 50; i++) printf("=");
    printf("\n");
    printf("Human intent → C implementation ✓\n");

    token_bucket_destroy(limiter);
    return 0;
}
