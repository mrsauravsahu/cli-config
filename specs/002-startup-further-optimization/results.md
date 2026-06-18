# Shell Startup Further Optimization — Results

**Status:** Pending

**Baseline:** post-zimfw migration — wall time ~1.1s  
**Target:** < 400ms wall time

---

## Wall Time

| | Baseline (zimfw) | After | Improvement |
|---|---|---|---|
| Wall time | 1.097s | — | — |
| User time | 0.36s | — | — |
| System time | 0.43s | — | — |

---

## Fix Status

| Fix | Est. saving | Status | Actual saving |
|---|---|---|---|
| Cache `compinit` | 200–375ms | Pending | — |
| Purge antigen residual | 80ms | Pending | — |
| Lazy-load `thefuck` | 100–300ms | Pending | — |
| Lazy-load `pyenv init` | 100–200ms | Pending | — |
| Cache `oh-my-posh init` output | 30–80ms | Pending | — |
| Re-enable `nvm` lazy-load | 30–100ms | Pending | — |
| Native `CLI_CONFIG_ROOT` detection | 2–10ms | Pending | — |
| Remove `.zwc` cleanup from `.zshrc` | 5–20ms | Pending | — |

---

See `plans.md` for implementation details on each fix.
