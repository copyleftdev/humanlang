#!/usr/bin/env bash
# Human Lang - Quick Test (Core Languages Only)
# Tests a subset of languages to prove the concept

set -euo pipefail

cd "$(dirname "$0")/.."

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Human Lang - Quick Validation (Core Languages)          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

mkdir -p results

PASSED=0
FAILED=0

run_lang() {
    local name="$1"
    local service="$2"
    
    printf "  %-12s " "$name"
    
    if timeout 180 docker compose build "$service" > /dev/null 2>&1 && \
       timeout 60 docker compose run --rm "$service" > "results/$service.log" 2>&1; then
        if grep -qi "implementation" "results/$service.log"; then
            echo -e "${GREEN}✓ PASSED${NC}"
            ((PASSED++))
            return 0
        fi
    fi
    echo -e "${RED}✗ FAILED${NC}"
    ((FAILED++))
    return 1
}

echo "Testing core languages:"
echo "-----------------------"

# Fast interpreted languages first
echo -e "\n${BLUE}[ Interpreted ]${NC}"
run_lang "Python" "python" || true
run_lang "JavaScript" "javascript" || true
run_lang "Ruby" "ruby" || true
run_lang "PHP" "php" || true
run_lang "Perl" "perl" || true
run_lang "Bash" "bash" || true

# Compiled languages
echo -e "\n${BLUE}[ Compiled ]${NC}"
run_lang "Go" "go" || true
run_lang "C" "c" || true
run_lang "Rust" "rust" || true

# Functional
echo -e "\n${BLUE}[ Functional ]${NC}"
run_lang "Haskell" "haskell" || true
run_lang "Elixir" "elixir" || true

echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "  Passed: ${GREEN}$PASSED${NC}  Failed: ${RED}$FAILED${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Full logs in results/"
