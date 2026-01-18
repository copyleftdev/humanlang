#!/usr/bin/env bash
# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.
#
# Bash: The shell that glues Unix together.
# Human intent, one pipe at a time.

set -euo pipefail

# Token bucket state (using temp file for persistence across function calls)
BUCKET_FILE=$(mktemp)
trap "rm -f $BUCKET_FILE" EXIT

# Initialize bucket
init_bucket() {
    local capacity=$1
    local refill_rate=$2
    
    if (( $(echo "$capacity <= 0" | bc -l) )); then
        echo "Error: Capacity must be positive" >&2
        exit 1
    fi
    if (( $(echo "$refill_rate <= 0" | bc -l) )); then
        echo "Error: Refill rate must be positive" >&2
        exit 1
    fi
    
    cat > "$BUCKET_FILE" << EOF
CAPACITY=$capacity
REFILL_RATE=$refill_rate
TOKENS=$capacity
LAST_REFILL=$(date +%s.%N)
EOF
}

# Load bucket state
load_bucket() {
    source "$BUCKET_FILE"
}

# Save bucket state
save_bucket() {
    cat > "$BUCKET_FILE" << EOF
CAPACITY=$CAPACITY
REFILL_RATE=$REFILL_RATE
TOKENS=$TOKENS
LAST_REFILL=$LAST_REFILL
EOF
}

# Refill tokens based on elapsed time
refill() {
    load_bucket
    local now=$(date +%s.%N)
    local elapsed=$(echo "$now - $LAST_REFILL" | bc -l)
    
    if (( $(echo "$elapsed > 0" | bc -l) )); then
        local tokens_to_add=$(echo "$elapsed * $REFILL_RATE" | bc -l)
        TOKENS=$(echo "$TOKENS + $tokens_to_add" | bc -l)
        if (( $(echo "$TOKENS > $CAPACITY" | bc -l) )); then
            TOKENS=$CAPACITY
        fi
        LAST_REFILL=$now
    fi
    save_bucket
}

# Attempt to consume tokens
consume() {
    local tokens=${1:-1}
    refill
    load_bucket
    
    if (( $(echo "$TOKENS >= $tokens" | bc -l) )); then
        TOKENS=$(echo "$TOKENS - $tokens" | bc -l)
        save_bucket
        return 0  # Success
    fi
    return 1  # Failure
}

# Get available tokens
available() {
    refill
    load_bucket
    printf "%.2f" "$TOKENS"
}

get_capacity() {
    load_bucket
    echo "$CAPACITY"
}

get_refill_rate() {
    load_bucket
    echo "$REFILL_RATE"
}

# --- Demonstration ---

main() {
    echo "Token Bucket Rate Limiter - Bash Implementation"
    printf '%.0s=' {1..50}
    echo
    echo
    
    # Create a bucket: 5 tokens capacity, 2 tokens/second refill
    init_bucket 5 2
    
    echo "Created limiter: capacity=$(get_capacity), refill_rate=$(get_refill_rate)/s"
    echo "Starting tokens: $(printf '%.0f' "$(available)")"
    echo
    
    # Consume all tokens rapidly
    echo "--- Rapid consumption ---"
    for i in {1..7}; do
        if consume; then
            status="✓ allowed"
        else
            status="✗ denied"
        fi
        echo "  Attempt $i: $status (tokens left: $(available))"
    done
    echo
    
    # Wait for refill
    echo "--- Waiting 1 second for refill ---"
    sleep 1
    echo "Tokens after 1s: $(available)"
    echo
    
    # Try again
    echo "--- Post-refill consumption ---"
    for i in {1..3}; do
        if consume; then
            status="✓ allowed"
        else
            status="✗ denied"
        fi
        echo "  Attempt $i: $status (tokens left: $(available))"
    done
    echo
    
    printf '%.0s=' {1..50}
    echo
    echo "Human intent → Bash implementation ✓"
}

main "$@"
