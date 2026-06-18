---
name: zoekt
description: Reference for zoekt trigram-based code search syntax. Use this skill whenever the user wants to search code with zoekt, write a zoekt query, filter by language/file/repo/branch, use regex in zoekt, or asks how to search for symbols, archived repos, forks, or branches in zoekt. Trigger on any mention of "zoekt", "zoekt query", or questions like "how do I search for X in zoekt".
---

# Zoekt Search Syntax

Zoekt is a trigram-based code search engine. Here's the full query syntax:

## Basic search

| Query | Meaning |
|-------|---------|
| `needle` | Search for "needle" (case insensitive by default) |
| `thread or needle` | Files containing either "thread" or "needle" |
| `class needle` | Files containing both "class" and "needle" |
| `class Needle` | "class" case-insensitively AND "Needle" case-sensitively |
| `class Needle case:yes` | Both "class" and "Needle" case-sensitively |
| `"class Needle"` | Exact phrase "class Needle" |

## Negation

| Query | Meaning |
|-------|---------|
| `needle -hay` | Files with "needle" but NOT "hay" |
| `-(Path File) Stream` | "Stream", excluding files containing both "Path" and "File" |
| `-Path\ file Stream` | "Stream", excluding files containing "Path File" |

## File filters

| Query | Meaning |
|-------|---------|
| `path file:java` | "path" in files whose name contains "java" |
| `path -file:java` | "path" excluding files whose name contains "java" |
| `f:\.c$` | Files whose name ends with ".c" (regex) |

## Language filter

| Query | Meaning |
|-------|---------|
| `needle lang:python` | "needle" in Python source files |

## Repository filters

| Query | Meaning |
|-------|---------|
| `phone r:droid` | "phone" in repos whose name contains "droid" |
| `phone archived:no` | "phone" in non-archived repos |
| `phone fork:no` | "phone" in non-fork repos |
| `phone public:no` | "phone" in non-public repos |

## Branch filters (Git)

| Query | Meaning |
|-------|---------|
| `phone b:master` | "phone" in branches whose name contains "master" |
| `phone b:HEAD` | "phone" in the default (HEAD) branch |

## Symbol search

| Query | Meaning |
|-------|---------|
| `sym:data` | Symbol definitions containing "data" |

## Regex

Any query term that looks like a regex is treated as one:

| Query | Meaning |
|-------|---------|
| `foo.*bar` | Files matching regex `foo.*bar` |
| `f:\.c$` | Files with names matching regex `\.c$` |

## Tips

- Unquoted terms are AND-ed together by default
- Use `or` between terms for OR logic
- Wrap phrases in double quotes for exact match
- Prefix with `-` to negate a term or group
- `case:yes` makes ALL terms in the query case-sensitive
- Uppercase letters in a term make that term case-sensitive automatically
- `sym:` searches symbol definitions, not arbitrary text
- `file:` / `f:` accept regex patterns
- `r:` filters by repository name (also accepts regex)
