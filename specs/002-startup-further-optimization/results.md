# Shell Startup Further Optimization — Results

**Status:** In progress

**Baseline:** post-zimfw migration — wall time ~1.1s  
**Target:** < 400ms wall time

---

## Wall Time

| | Baseline (zimfw) | After compinit + CLI_CONFIG_ROOT fixes | Improvement |
|---|---|---|---|
| Wall time | 1.097s | ~0.6–0.7s | ~0.4s |
| User time | 0.36s | ~0.23s | ~0.13s |
| System time | 0.43s | ~0.12s | ~0.31s |

`compinit` self-time in zprof dropped from ~2.7s (84% of profiled time) to ~8ms.

---

## Fix Status

| Fix | Est. saving | Status | Actual saving |
|---|---|---|---|
| Cache `compinit` | 200–375ms | **Done** | ~2.7s of zprof self-time eliminated; wall time down ~0.4s |
| Purge antigen residual | 80ms | Pending | — |
| Lazy-load `thefuck` | 100–300ms | Pending | — |
| Lazy-load `pyenv init` | 100–200ms | Pending | — |
| Cache `oh-my-posh init` output | 30–80ms | Pending | — |
| Re-enable `nvm` lazy-load | 30–100ms | Pending | — |
| Native `CLI_CONFIG_ROOT` detection | 2–10ms | **Done** | ~70ms (4-process pipeline → zsh param expansion) |
| Remove `.zwc` cleanup from `.zshrc` | 5–20ms | Pending | — |
| Remove duplicate `golang/set-env.zsh` source | negligible | **Done** | — |

---

See `plans.md` for implementation details on each fix. See `../CHANGELOG.md` for the dated change log.
