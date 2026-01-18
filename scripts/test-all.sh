#!/usr/bin/env bash
# Test all languages and report pass/fail

set -uo pipefail
cd "$(dirname "$0")/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

LANGS=(python javascript typescript go rust c haskell ruby elixir php perl lua erlang clojure kotlin swift dart julia scala groovy fortran prolog racket nim crystal zig d ocaml fsharp lisp r pascal ada cobol assembly bash brainfuck)

echo "Testing all languages..."
echo ""

PASSED=()
FAILED=()

for lang in "${LANGS[@]}"; do
    printf "%-12s " "$lang"
    if timeout 120 ./showcase.sh "$lang" > "/tmp/test_$lang.log" 2>&1; then
        if grep -q "completed successfully" "/tmp/test_$lang.log"; then
            echo -e "${GREEN}✓ PASS${NC}"
            PASSED+=("$lang")
        else
            echo -e "${RED}✗ FAIL (no success message)${NC}"
            FAILED+=("$lang")
        fi
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED+=("$lang")
    fi
done

echo ""
echo "================================"
echo -e "Passed: ${GREEN}${#PASSED[@]}${NC}"
echo -e "Failed: ${RED}${#FAILED[@]}${NC}"
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Failed languages:"
    for lang in "${FAILED[@]}"; do
        echo "  - $lang"
    done
fi
