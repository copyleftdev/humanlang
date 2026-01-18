#!/usr/bin/env bash
# Human Lang - Run All Implementations
# Executes each language implementation and captures output

set -euo pipefail

cd "$(dirname "$0")/.."

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RESULTS_DIR="results"
mkdir -p "$RESULTS_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Human Lang - Universal Execution Suite              ║"
echo "║     38 Languages, One Intent, Proving the Paradigm Shift     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

TOTAL=0
PASSED=0
FAILED=0

run_language() {
    local name="$1"
    local service="$2"
    
    ((TOTAL++)) || true
    
    printf "  %-15s " "$name"
    
    if timeout 120 docker compose run --rm "$service" > "$RESULTS_DIR/$service.log" 2>&1; then
        if grep -qi "implementation" "$RESULTS_DIR/$service.log" && \
           grep -qi "allowed" "$RESULTS_DIR/$service.log"; then
            echo -e "${GREEN}✓ PASSED${NC}"
            ((PASSED++)) || true
        else
            echo -e "${YELLOW}? OUTPUT UNEXPECTED${NC}"
            ((FAILED++)) || true
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++)) || true
    fi
}

echo "Building containers (this may take a while on first run)..."
echo ""

# Build all containers first
docker compose build --parallel 2>/dev/null || docker compose build

echo ""
echo "Running implementations:"
echo "------------------------"

# Mainstream
echo -e "\n${BLUE}[ Mainstream Languages ]${NC}"
run_language "Python" "python"
run_language "JavaScript" "javascript"
run_language "TypeScript" "typescript"
run_language "Rust" "rust"
run_language "Go" "go"
run_language "C" "c"

# Functional
echo -e "\n${BLUE}[ Functional Languages ]${NC}"
run_language "Haskell" "haskell"
run_language "Elixir" "elixir"
run_language "Erlang" "erlang"
run_language "Clojure" "clojure"
run_language "OCaml" "ocaml"
run_language "F#" "fsharp"
run_language "Scala" "scala"
run_language "Racket" "racket"

# Scripting
echo -e "\n${BLUE}[ Scripting Languages ]${NC}"
run_language "Ruby" "ruby"
run_language "Lua" "lua"
run_language "Perl" "perl"
run_language "PHP" "php"
run_language "Bash" "bash"
run_language "Groovy" "groovy"

# Systems
echo -e "\n${BLUE}[ Systems Languages ]${NC}"
run_language "Zig" "zig"
run_language "Nim" "nim"
run_language "Crystal" "crystal"
run_language "D" "d"

# JVM/Modern
echo -e "\n${BLUE}[ JVM/Modern Languages ]${NC}"
run_language "Kotlin" "kotlin"
run_language "Swift" "swift"
run_language "Dart" "dart"

# Scientific
echo -e "\n${BLUE}[ Scientific Languages ]${NC}"
run_language "Julia" "julia"
run_language "R" "r"
run_language "Fortran" "fortran"

# Classic
echo -e "\n${BLUE}[ Classic Languages ]${NC}"
run_language "Pascal" "pascal"
run_language "Ada" "ada"
run_language "COBOL" "cobol"

# Logic/Lisp
echo -e "\n${BLUE}[ Logic/Lisp Languages ]${NC}"
run_language "Common Lisp" "lisp"
run_language "Prolog" "prolog"

# Low-level
echo -e "\n${BLUE}[ Low-level ]${NC}"
run_language "x86 Assembly" "assembly"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                        RESULTS                               ║"
echo "╠══════════════════════════════════════════════════════════════╣"
printf "║  Total: %-4d  Passed: ${GREEN}%-4d${NC}  Failed: ${RED}%-4d${NC}                  ║\n" "$TOTAL" "$PASSED" "$FAILED"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Detailed logs saved to: $RESULTS_DIR/"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All implementations validated successfully!${NC}"
    echo "Human language truly is the universal programming language."
    exit 0
else
    echo -e "${YELLOW}Some implementations need attention.${NC}"
    echo "Check individual logs in $RESULTS_DIR/ for details."
    exit 1
fi
