# Human Lang

![Languages](https://img.shields.io/badge/languages-37-blue?style=flat-square)
![Years](https://img.shields.io/badge/1957–2016-60%20years-orange?style=flat-square)
![Intent](https://img.shields.io/badge/source-human%20intent-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)
![Docker](https://img.shields.io/badge/docker-required-blue?style=flat-square&logo=docker&logoColor=white)
![Status](https://img.shields.io/badge/all%2037-passing-success?style=flat-square)

## 1957 → 2016. Sixty years of syntax. One human intent.

---

In 1957, a team at IBM created Fortran to help scientists speak to machines.

In 2016, Andrew Kelley released Zig to help programmers speak to machines *better*.

Between them: COBOL, Lisp, C, Pascal, Ada, Perl, Python, Haskell, Ruby, Rust, Go—dozens of languages, each promising to close the gap between human thought and machine instruction.

We called them "high-level" when they read almost like English.
We celebrated when code became "readable."
We argued about tabs versus spaces. (Spoiler: neither mattered.)

**But we had it backwards.**

We spent sixty years training humans to think like machines.

---

## The Convergence

Something changed.

Information is collapsing inward. The distance between what you *mean* and what you can *make* is shrinking to zero.

Today, a single human intent—expressed in plain language—can be transpiled into *any* programming language. Not translated. Not approximated. **Directly manifested.**

```
Intent → {Fortran, Lisp, C, Python, Haskell, Rust, Zig, ...}
```

The source code is no longer syntax.

**The source code is the idea itself.**

---

## The Experiment

We wrote one intent:

> *A bucket holds tokens. It refills at a steady rate, up to a maximum. Each action consumes a token. Empty bucket? Wait. This controls how fast things can happen.*

Then we asked: can this single idea, expressed in human language, become working code in every major programming language from the last six decades?

**37 languages said yes.**

*(Brainfuck said `+++++[>+++++++>...` but that counts.)*

---

## The Proof

```
./showcase.sh --all
```

| 1957 | Fortran | The scientific OG |
|------|---------|-------------------|
| 1958 | Lisp | The AI original |
| 1959 | COBOL | The banking one |
| 1970 | Pascal | The teaching one |
| 1972 | C | The foundation |
| 1972 | Prolog | The reasoning one |
| 1978 | Assembly | The bare metal |
| 1980 | Ada | The aerospace one |
| 1984 | Common Lisp | The evolved one |
| 1986 | Erlang | The telecom one |
| 1987 | Perl | The duct tape |
| 1989 | Bash | The shell |
| 1990 | Haskell | The pure one |
| 1991 | Python | The readable one |
| 1993 | Lua | The embedded one |
| 1993 | R | The data one |
| 1993 | Brainfuck | The absurd one |
| 1995 | JavaScript | The everywhere one |
| 1995 | Ruby | The happy one |
| 1995 | PHP | The web one |
| 1995 | Racket | The teaching Lisp |
| 1996 | OCaml | The ML descendant |
| 2001 | D | The better C++ |
| 2003 | Groovy | The scripting Java |
| 2004 | Scala | The academic one |
| 2005 | F# | The .NET functional |
| 2007 | Clojure | The JVM Lisp |
| 2008 | Nim | The efficient one |
| 2009 | Go | The simple one |
| 2010 | Rust | The safe one |
| 2011 | Kotlin | The modern JVM |
| 2011 | Elixir | The modern Erlang |
| 2011 | Dart | The Flutter one |
| 2012 | TypeScript | The typed JavaScript |
| 2012 | Julia | The fast Python |
| 2014 | Swift | The Apple one |
| 2014 | Crystal | The fast Ruby |
| 2016 | Zig | The better C |

Every folder contains working code. Same behavior. Same output. Different syntax.

Not copied from each other. Each transpiled directly from English.

---

## Run It

```bash
./showcase.sh                    # Interactive showcase
./showcase.sh python rust zig    # Specific languages
./showcase.sh --all              # All 37 languages
./scripts/test-all.sh            # Verify everything passes
```

**Output (identical across all languages):**

```
Token Bucket Rate Limiter
==================================================
  Attempt 1: ✓ allowed (tokens left: 4.00)
  Attempt 2: ✓ allowed (tokens left: 3.00)
  Attempt 3: ✓ allowed (tokens left: 2.00)
  Attempt 4: ✓ allowed (tokens left: 1.00)
  Attempt 5: ✓ allowed (tokens left: 0.00)
  Attempt 6: ✗ denied  (tokens left: 0.00)
  
--- Waiting 1 second for refill ---
Tokens after 1s: 2.00

✓ Completed successfully
```

---

## The Letting Go

This is hard to accept.

If you spent years mastering syntax—memorizing APIs, debugging semicolons, internalizing the quirks of a language—this feels like a loss. That knowledge was *expensive*. It took thousands of hours. It became part of your identity.

And now someone says: *"Just describe what you want."*

It sounds like a shortcut. Like cheating. Like "vibe coding."

*(Okay, maybe it is vibe coding. But vibes were always the point.)*

**Here's what's actually happening:**

The complexity didn't disappear. It moved.

Syntax mastery was never the point—it was the *tax* we paid to reach the point. The point was always the idea. The architecture. The clear understanding of what needed to exist and why.

---

## The New Skill

What matters now isn't knowing *how* to write a rate limiter in Rust.

It's knowing *what* a rate limiter is. *Why* it exists. *When* to use it. What tradeoffs it makes. How it fits into a system.

**First principles.**

The programmers who thrive now aren't the ones who memorized the most syntax. They're the ones who understand:

- How systems fail and why
- What makes software maintainable
- When to choose consistency vs. availability
- Why some abstractions leak and others don't
- What users actually need vs. what they ask for

AI handles the middle—the translation from intent to implementation.

Humans handle the edges—the *what* and the *why*.

---

## Why Software Gets Better

For sixty years, we filtered who could build software by who could learn syntax.

That filter caught some brilliant minds. It also blocked many others—people who understood systems deeply but couldn't (or didn't want to) spend years on semicolons.

Now that filter is dissolving.

A domain expert who deeply understands healthcare can build healthcare software.
A musician who deeply understands audio can build audio tools.
A teacher who deeply understands learning can build educational software.

**The people closest to the problem can now build the solution.**

That's not dumbing down software.

That's software finally getting access to the people who understand it best.

*(The syntax gatekeepers can relax now. Or learn healthcare. Either way.)*

---

## What This Means

**Language is now a compile target, not a skill.**

You don't need to "know" Haskell to ship Haskell.
You need to know what you want to build.

**Intent is portable.**

The same idea, expressed once, runs anywhere—any paradigm, any runtime, any ecosystem.

**The bottleneck shifted.**

It's no longer "can you code this?"
It's "can you think this clearly?"

---

## The Source of Truth

```
INTENT.md
```

Read it. That's the program.

Everything else—Python, Rust, COBOL, Assembly—is a build artifact.

---

## Add a Language

1. Read `INTENT.md`
2. Implement the intent idiomatically
3. Submit a PR

No translation from other implementations. Only from the intent.

---

## Requirements

- Docker
- ~10GB disk space
- Curiosity

---

## License

MIT — The idea is free. Build something.

---

<p align="center">
<i>Sixty years of programming languages.</i><br>
<i>One human intent.</i><br><br>
<b>The best programming language is the one you already speak.</b>
</p>
