#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                    HUMAN LANG SHOWCASE                           ║
# ║         Intent is the Ultimate Programming Language              ║
# ╚══════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./showcase.sh                    # Interactive menu
#   ./showcase.sh python             # Run specific language
#   ./showcase.sh python rust go     # Run multiple languages
#   ./showcase.sh --all              # Run all languages
#   ./showcase.sh --list             # List available languages

set -euo pipefail

cd "$(dirname "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# Box drawing
BOX_TL="╔" BOX_TR="╗" BOX_BL="╚" BOX_BR="╝"
BOX_H="═" BOX_V="║"

banner() {
    echo ""
    echo -e "${CYAN}${BOX_TL}$(printf '═%.0s' {1..66})${BOX_TR}${NC}"
    echo -e "${CYAN}${BOX_V}${NC}${WHITE}                      HUMAN LANG SHOWCASE                        ${NC}${CYAN}${BOX_V}${NC}"
    echo -e "${CYAN}${BOX_V}${NC}${DIM}            Intent is the Ultimate Programming Language           ${NC}${CYAN}${BOX_V}${NC}"
    echo -e "${CYAN}${BOX_BL}$(printf '═%.0s' {1..66})${BOX_BR}${NC}"
    echo ""
}

# Language configurations (embedded for simplicity)
declare -A LANG_IMAGE LANG_SETUP LANG_FILE LANG_BUILD LANG_RUN LANG_NAME LANG_YEAR LANG_TAG

init_languages() {
    # Python
    LANG_NAME[python]="Python"; LANG_YEAR[python]="1991"; LANG_TAG[python]="The readable one"
    LANG_IMAGE[python]="python:3.12-slim"; LANG_FILE[python]="python/rate_limiter.py"
    LANG_RUN[python]="python rate_limiter.py"

    # JavaScript
    LANG_NAME[javascript]="JavaScript"; LANG_YEAR[javascript]="1995"; LANG_TAG[javascript]="The browser one"
    LANG_IMAGE[javascript]="node:20-slim"; LANG_FILE[javascript]="javascript/rate_limiter.js"
    LANG_RUN[javascript]="node rate_limiter.js"

    # Go
    LANG_NAME[go]="Go"; LANG_YEAR[go]="2009"; LANG_TAG[go]="The simple one"
    LANG_IMAGE[go]="golang:1.22-alpine"; LANG_FILE[go]="go/"
    LANG_BUILD[go]="go build -o rate_limiter *.go"; LANG_RUN[go]="./rate_limiter"

    # Rust
    LANG_NAME[rust]="Rust"; LANG_YEAR[rust]="2010"; LANG_TAG[rust]="The safe one"
    LANG_IMAGE[rust]="rust:1.75-slim"; LANG_FILE[rust]="rust/"
    LANG_BUILD[rust]="cargo build --release 2>/dev/null"; LANG_RUN[rust]="./target/release/rate_limiter"

    # C
    LANG_NAME[c]="C"; LANG_YEAR[c]="1972"; LANG_TAG[c]="The OG"
    LANG_IMAGE[c]="gcc:13"; LANG_FILE[c]="c/"
    LANG_BUILD[c]="make"; LANG_RUN[c]="./rate_limiter"

    # Haskell
    LANG_NAME[haskell]="Haskell"; LANG_YEAR[haskell]="1990"; LANG_TAG[haskell]="The pure one"
    LANG_IMAGE[haskell]="haskell:9.4"; LANG_FILE[haskell]="haskell/RateLimiter.hs"
    LANG_BUILD[haskell]="ghc -o rate_limiter RateLimiter.hs 2>/dev/null"; LANG_RUN[haskell]="./rate_limiter"

    # Ruby
    LANG_NAME[ruby]="Ruby"; LANG_YEAR[ruby]="1995"; LANG_TAG[ruby]="The happy one"
    LANG_IMAGE[ruby]="ruby:3.3-slim"; LANG_FILE[ruby]="ruby/rate_limiter.rb"
    LANG_RUN[ruby]="ruby rate_limiter.rb"

    # Elixir
    LANG_NAME[elixir]="Elixir"; LANG_YEAR[elixir]="2011"; LANG_TAG[elixir]="The modern Erlang"
    LANG_IMAGE[elixir]="elixir:1.16-slim"; LANG_FILE[elixir]="elixir/rate_limiter.exs"
    LANG_RUN[elixir]="elixir rate_limiter.exs"

    # PHP
    LANG_NAME[php]="PHP"; LANG_YEAR[php]="1995"; LANG_TAG[php]="The web one"
    LANG_IMAGE[php]="php:8.3-cli"; LANG_FILE[php]="php/rate_limiter.php"
    LANG_RUN[php]="php rate_limiter.php"

    # Perl
    LANG_NAME[perl]="Perl"; LANG_YEAR[perl]="1987"; LANG_TAG[perl]="The duct tape"
    LANG_IMAGE[perl]="perl:5.38"; LANG_FILE[perl]="perl/rate_limiter.pl"
    LANG_RUN[perl]="perl rate_limiter.pl"

    # Erlang
    LANG_NAME[erlang]="Erlang"; LANG_YEAR[erlang]="1986"; LANG_TAG[erlang]="The telecom one"
    LANG_IMAGE[erlang]="erlang:26-slim"; LANG_FILE[erlang]="erlang/rate_limiter.erl"
    LANG_BUILD[erlang]="erlc rate_limiter.erl"; LANG_RUN[erlang]="erl -noshell -s rate_limiter demo -s init stop"

    # Clojure
    LANG_NAME[clojure]="Clojure"; LANG_YEAR[clojure]="2007"; LANG_TAG[clojure]="The JVM Lisp"
    LANG_IMAGE[clojure]="clojure:temurin-21-tools-deps"; LANG_FILE[clojure]="clojure/rate_limiter.clj"
    LANG_RUN[clojure]="clojure -M rate_limiter.clj"

    # Swift
    LANG_NAME[swift]="Swift"; LANG_YEAR[swift]="2014"; LANG_TAG[swift]="The Apple one"
    LANG_IMAGE[swift]="swift:5.9"; LANG_FILE[swift]="swift/rate_limiter.swift"
    LANG_BUILD[swift]="swiftc -O -o rate_limiter rate_limiter.swift 2>/dev/null"; LANG_RUN[swift]="./rate_limiter"

    # Dart
    LANG_NAME[dart]="Dart"; LANG_YEAR[dart]="2011"; LANG_TAG[dart]="The Flutter one"
    LANG_IMAGE[dart]="dart:3.2"; LANG_FILE[dart]="dart/rate_limiter.dart"
    LANG_RUN[dart]="dart run rate_limiter.dart"

    # Julia
    LANG_NAME[julia]="Julia"; LANG_YEAR[julia]="2012"; LANG_TAG[julia]="The fast Python"
    LANG_IMAGE[julia]="julia:1.10"; LANG_FILE[julia]="julia/rate_limiter.jl"
    LANG_RUN[julia]="julia rate_limiter.jl"

    # Scala
    LANG_NAME[scala]="Scala"; LANG_YEAR[scala]="2004"; LANG_TAG[scala]="The academic one"
    LANG_IMAGE[scala]="hseeberger/scala-sbt:17.0.2_1.6.2_3.1.1"
    LANG_FILE[scala]="scala/RateLimiter.scala"
    LANG_BUILD[scala]="scalac RateLimiter.scala 2>/dev/null"; LANG_RUN[scala]="scala RateLimiter"

    # Groovy
    LANG_NAME[groovy]="Groovy"; LANG_YEAR[groovy]="2003"; LANG_TAG[groovy]="The scripting Java"
    LANG_IMAGE[groovy]="groovy:4.0-jdk21"; LANG_FILE[groovy]="groovy/RateLimiter.groovy"
    LANG_RUN[groovy]="groovy RateLimiter.groovy"

    # Fortran
    LANG_NAME[fortran]="Fortran"; LANG_YEAR[fortran]="1957"; LANG_TAG[fortran]="The scientific OG"
    LANG_IMAGE[fortran]="gcc:13"; LANG_FILE[fortran]="fortran/rate_limiter.f90"
    LANG_BUILD[fortran]="gfortran -O2 -o rate_limiter rate_limiter.f90"; LANG_RUN[fortran]="./rate_limiter"

    # Prolog
    LANG_NAME[prolog]="Prolog"; LANG_YEAR[prolog]="1972"; LANG_TAG[prolog]="The reasoning one"
    LANG_IMAGE[prolog]="swipl:stable"; LANG_FILE[prolog]="prolog/rate_limiter.pl"
    LANG_RUN[prolog]="swipl -g demo -t halt rate_limiter.pl"

    # Racket
    LANG_NAME[racket]="Racket"; LANG_YEAR[racket]="1995"; LANG_TAG[racket]="The teaching one"
    LANG_IMAGE[racket]="racket/racket:8.11"; LANG_FILE[racket]="racket/rate_limiter.rkt"
    LANG_RUN[racket]="racket rate_limiter.rkt"

    # Nim
    LANG_NAME[nim]="Nim"; LANG_YEAR[nim]="2008"; LANG_TAG[nim]="The efficient one"
    LANG_IMAGE[nim]="nimlang/nim:2.0.2"; LANG_FILE[nim]="nim/rate_limiter.nim"
    LANG_BUILD[nim]="nim c -d:release rate_limiter.nim 2>/dev/null"; LANG_RUN[nim]="./rate_limiter"

    # Crystal
    LANG_NAME[crystal]="Crystal"; LANG_YEAR[crystal]="2014"; LANG_TAG[crystal]="The fast Ruby"
    LANG_IMAGE[crystal]="crystallang/crystal:1.11"; LANG_FILE[crystal]="crystal/rate_limiter.cr"
    LANG_BUILD[crystal]="crystal build --release rate_limiter.cr 2>/dev/null"; LANG_RUN[crystal]="./rate_limiter"

    # Zig - use Debian and download Zig
    LANG_NAME[zig]="Zig"; LANG_YEAR[zig]="2016"; LANG_TAG[zig]="The better C"
    LANG_IMAGE[zig]="debian:bookworm-slim"
    LANG_SETUP[zig]="apt-get update && apt-get install -y wget xz-utils && wget -q https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz && tar xf zig-linux-x86_64-0.11.0.tar.xz && mv zig-linux-x86_64-0.11.0 /opt/zig && ln -s /opt/zig/zig /usr/local/bin/zig"
    LANG_FILE[zig]="zig/rate_limiter.zig"
    LANG_BUILD[zig]="zig build-exe rate_limiter.zig -O ReleaseFast 2>/dev/null"; LANG_RUN[zig]="./rate_limiter"

    # Bash
    LANG_NAME[bash]="Bash"; LANG_YEAR[bash]="1989"; LANG_TAG[bash]="The shell one"
    LANG_IMAGE[bash]="bash:5"; LANG_SETUP[bash]="apk add --no-cache bc coreutils"
    LANG_FILE[bash]="bash/rate_limiter.sh"
    LANG_RUN[bash]="bash rate_limiter.sh"

    # Brainfuck - the esoteric one (prints "Hello World" as proof of concept)
    LANG_NAME[brainfuck]="Brainfuck"; LANG_YEAR[brainfuck]="1993"; LANG_TAG[brainfuck]="The esoteric one"
    LANG_IMAGE[brainfuck]="debian:bookworm-slim"
    LANG_SETUP[brainfuck]="apt-get update -qq && apt-get install -y -qq beef"
    LANG_FILE[brainfuck]="brainfuck/"
    LANG_RUN[brainfuck]="echo 'Token Bucket Rate Limiter - Brainfuck Implementation' && echo '==================================================' && echo '' && echo 'Brainfuck: The most esoteric language bows to human intent.' && echo 'See rate_limiter.bf for the documented implementation.' && echo '' && echo 'Running minimal demo:' && beef demo.bf && echo '' && echo '==================================================' && echo 'Human intent -> Brainfuck proof of concept'"

    # TypeScript
    LANG_NAME[typescript]="TypeScript"; LANG_YEAR[typescript]="2012"; LANG_TAG[typescript]="The typed JavaScript"
    LANG_IMAGE[typescript]="node:20-slim"
    LANG_SETUP[typescript]="npm install -g tsx 2>/dev/null"
    LANG_FILE[typescript]="typescript/rate_limiter.ts"
    LANG_RUN[typescript]="tsx rate_limiter.ts"

    # Lua
    LANG_NAME[lua]="Lua"; LANG_YEAR[lua]="1993"; LANG_TAG[lua]="The embedded one"
    LANG_IMAGE[lua]="alpine:3.19"
    LANG_SETUP[lua]="apk add --no-cache lua5.4"
    LANG_FILE[lua]="lua/rate_limiter.lua"
    LANG_RUN[lua]="lua5.4 rate_limiter.lua"

    # Kotlin
    LANG_NAME[kotlin]="Kotlin"; LANG_YEAR[kotlin]="2011"; LANG_TAG[kotlin]="The modern JVM"
    LANG_IMAGE[kotlin]="eclipse-temurin:21-jdk"
    LANG_SETUP[kotlin]="apt-get update && apt-get install -y unzip zip curl && curl -s https://get.sdkman.io | bash && bash -c 'source /root/.sdkman/bin/sdkman-init.sh && sdk install kotlin'"
    LANG_FILE[kotlin]="kotlin/RateLimiter.kt"
    LANG_BUILD[kotlin]="bash -c 'source /root/.sdkman/bin/sdkman-init.sh && kotlinc RateLimiter.kt -include-runtime -d rate_limiter.jar' 2>/dev/null"
    LANG_RUN[kotlin]="java -jar rate_limiter.jar"

    # D
    LANG_NAME[d]="D"; LANG_YEAR[d]="2001"; LANG_TAG[d]="The better C++"
    LANG_IMAGE[d]="debian:bookworm-slim"
    LANG_SETUP[d]="apt-get update && apt-get install -y wget gcc libcurl4 && wget -q https://downloads.dlang.org/releases/2.x/2.108.1/dmd_2.108.1-0_amd64.deb && dpkg -i dmd_2.108.1-0_amd64.deb"
    LANG_FILE[d]="d/rate_limiter.d"
    LANG_BUILD[d]="dmd -of=rate_limiter rate_limiter.d 2>/dev/null"; LANG_RUN[d]="./rate_limiter"

    # OCaml
    LANG_NAME[ocaml]="OCaml"; LANG_YEAR[ocaml]="1996"; LANG_TAG[ocaml]="The ML descendant"
    LANG_IMAGE[ocaml]="ocaml/opam:debian-12-ocaml-5.1"
    LANG_FILE[ocaml]="ocaml/rate_limiter.ml"
    LANG_BUILD[ocaml]="ocamlfind ocamlopt -package unix -linkpkg -o rate_limiter rate_limiter.ml 2>/dev/null || ocamlopt -I +unix unix.cmxa -o rate_limiter rate_limiter.ml 2>/dev/null"
    LANG_RUN[ocaml]="./rate_limiter"

    # F#
    LANG_NAME[fsharp]="F#"; LANG_YEAR[fsharp]="2005"; LANG_TAG[fsharp]="The .NET functional"
    LANG_IMAGE[fsharp]="mcr.microsoft.com/dotnet/sdk:8.0"
    LANG_FILE[fsharp]="fsharp/RateLimiter.fs"
    LANG_RUN[fsharp]="dotnet fsi RateLimiter.fs 2>/dev/null | head -30"

    # Common Lisp
    LANG_NAME[lisp]="Common Lisp"; LANG_YEAR[lisp]="1984"; LANG_TAG[lisp]="The original"
    LANG_IMAGE[lisp]="debian:bookworm-slim"
    LANG_SETUP[lisp]="apt-get update && apt-get install -y sbcl"
    LANG_FILE[lisp]="lisp/rate_limiter.lisp"
    LANG_RUN[lisp]="sbcl --script rate_limiter.lisp"

    # R
    LANG_NAME[r]="R"; LANG_YEAR[r]="1993"; LANG_TAG[r]="The data science one"
    LANG_IMAGE[r]="r-base:4.3.2"
    LANG_SETUP[r]="Rscript -e \"if(!require('R6')) install.packages('R6', repos='https://cloud.r-project.org/')\" 2>/dev/null"
    LANG_FILE[r]="r/rate_limiter.R"
    LANG_RUN[r]="Rscript rate_limiter.R"

    # Pascal
    LANG_NAME[pascal]="Pascal"; LANG_YEAR[pascal]="1970"; LANG_TAG[pascal]="The teaching one"
    LANG_IMAGE[pascal]="debian:bookworm-slim"
    LANG_SETUP[pascal]="apt-get update && apt-get install -y fpc"
    LANG_FILE[pascal]="pascal/rate_limiter.pas"
    LANG_BUILD[pascal]="fpc -O2 rate_limiter.pas 2>/dev/null"; LANG_RUN[pascal]="./rate_limiter"

    # Ada
    LANG_NAME[ada]="Ada"; LANG_YEAR[ada]="1980"; LANG_TAG[ada]="The aerospace one"
    LANG_IMAGE[ada]="debian:bookworm-slim"
    LANG_SETUP[ada]="apt-get update && apt-get install -y gnat"
    LANG_FILE[ada]="ada/rate_limiter.adb"
    LANG_BUILD[ada]="gnatmake rate_limiter.adb -o rate_limiter"; LANG_RUN[ada]="./rate_limiter"

    # COBOL
    LANG_NAME[cobol]="COBOL"; LANG_YEAR[cobol]="1959"; LANG_TAG[cobol]="The banking one"
    LANG_IMAGE[cobol]="debian:bookworm-slim"
    LANG_SETUP[cobol]="apt-get update && apt-get install -y gnucobol"
    LANG_FILE[cobol]="cobol/RATELIMIT.cbl"
    LANG_BUILD[cobol]="cobc -x -free -o rate_limiter RATELIMIT.cbl 2>/dev/null"; LANG_RUN[cobol]="./rate_limiter"

    # x86-64 Assembly
    LANG_NAME[assembly]="x86-64 Assembly"; LANG_YEAR[assembly]="1978"; LANG_TAG[assembly]="The bare metal"
    LANG_IMAGE[assembly]="debian:bookworm-slim"
    LANG_SETUP[assembly]="apt-get update && apt-get install -y nasm binutils"
    LANG_FILE[assembly]="assembly-x86/rate_limiter.asm"
    LANG_BUILD[assembly]="nasm -f elf64 rate_limiter.asm -o rate_limiter.o && ld rate_limiter.o -o rate_limiter 2>/dev/null"
    LANG_RUN[assembly]="./rate_limiter"
}

list_languages() {
    echo -e "${WHITE}Available languages:${NC}"
    echo ""
    printf "  ${DIM}%-12s %-6s %s${NC}\n" "KEY" "YEAR" "DESCRIPTION"
    echo "  ─────────────────────────────────────────────"
    for key in $(echo "${!LANG_NAME[@]}" | tr ' ' '\n' | sort); do
        printf "  ${CYAN}%-12s${NC} ${DIM}%s${NC}  %s ${DIM}(%s)${NC}\n" \
            "$key" "${LANG_YEAR[$key]}" "${LANG_NAME[$key]}" "${LANG_TAG[$key]}"
    done
    echo ""
}

run_language() {
    local lang="$1"
    
    if [[ -z "${LANG_NAME[$lang]:-}" ]]; then
        echo -e "${RED}Unknown language: $lang${NC}"
        return 1
    fi

    local name="${LANG_NAME[$lang]}"
    local year="${LANG_YEAR[$lang]}"
    local tag="${LANG_TAG[$lang]}"
    local image="${LANG_IMAGE[$lang]}"
    local file="${LANG_FILE[$lang]}"
    local setup="${LANG_SETUP[$lang]:-}"
    local build="${LANG_BUILD[$lang]:-}"
    local run="${LANG_RUN[$lang]}"

    echo ""
    echo -e "${MAGENTA}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}│${NC} ${WHITE}${name}${NC} ${DIM}(${year})${NC} — ${tag}"
    echo -e "${MAGENTA}└──────────────────────────────────────────────────────────────────┘${NC}"
    echo -e "${DIM}Image: ${image}${NC}"
    echo ""

    # Build the docker command
    local docker_cmd="cd /app"
    [[ -n "$setup" ]] && docker_cmd="$setup && $docker_cmd"
    [[ -n "$build" ]] && docker_cmd="$docker_cmd && $build"
    docker_cmd="$docker_cmd && $run"

    # Determine what to copy
    local copy_src
    if [[ -d "$file" ]]; then
        copy_src="$file"
    else
        copy_src="$(dirname "$file")"
    fi

    # Run in Docker
    if docker run --rm -v "$(pwd)/$copy_src:/app" -w /app "$image" sh -c "$docker_cmd" 2>&1; then
        echo ""
        echo -e "${GREEN}✓ ${name} completed successfully${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ ${name} failed${NC}"
        return 1
    fi
}

# Main
init_languages

case "${1:-}" in
    --list|-l)
        banner
        list_languages
        ;;
    --all|-a)
        banner
        echo -e "${WHITE}Running ALL languages...${NC}"
        passed=0; failed=0
        for lang in $(echo "${!LANG_NAME[@]}" | tr ' ' '\n' | sort); do
            if run_language "$lang"; then
                ((passed++))
            else
                ((failed++))
            fi
        done
        echo ""
        echo -e "${WHITE}═══════════════════════════════════════════════════${NC}"
        echo -e "  ${GREEN}Passed: $passed${NC}  ${RED}Failed: $failed${NC}"
        echo -e "${WHITE}═══════════════════════════════════════════════════${NC}"
        ;;
    --help|-h)
        banner
        echo "Usage: $0 [OPTIONS] [LANGUAGE...]"
        echo ""
        echo "Options:"
        echo "  --list, -l     List available languages"
        echo "  --all, -a      Run all languages"
        echo "  --help, -h     Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 python              Run Python implementation"
        echo "  $0 python rust go      Run multiple implementations"
        echo "  $0 --all               Run all implementations"
        echo ""
        ;;
    "")
        banner
        echo -e "${WHITE}Quick showcase — proving human intent compiles everywhere${NC}"
        echo ""
        echo "Running: Python → Go → Rust → Haskell"
        echo ""
        for lang in python go rust haskell; do
            run_language "$lang"
        done
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}  Same intent. Same output. Four different languages.${NC}"
        echo -e "${DIM}  Run './showcase.sh --list' to see all 37 languages${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
        ;;
    *)
        banner
        for lang in "$@"; do
            run_language "$lang"
        done
        ;;
esac
