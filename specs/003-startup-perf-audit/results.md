# Shell Startup Perf Audit — Round 3

**Status:** Completed
**Baseline:** ~700ms wall (post-002)
**Result:** ~465ms wall — **231ms saved (33%)**

Measured with 12 interleaved baseline/patched runs of `zsh -i -c exit` (interleaving
cancels machine drift; sequential A/B runs were too noisy to read).

---

## Where the time actually went

Coarse phase timing (`$EPOCHREALTIME` markers around each section) was the only
reliable instrument here. `zprof` misses subprocess cost, and `setopt xtrace`
emitted 66k lines and distorted the very thing being measured.

| Phase | Cost |
|---|---|
| oh-my-posh `init zsh` | 103ms |
| compinit (full) | 95ms |
| thefuck `--alias` | 68ms |
| zimfw `init.zsh` | 54ms |
| everything else | ~3ms |
| **config subtotal** | **323ms** |
| global `/etc/zshrc` + `/etc/zprofile` | 90ms |

---

## The "sometimes it's very slow" bug

The 24h compinit cache guard from spec 002 was **permanently stuck in the slow path**:

```zsh
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
```

`compinit` only rewrites the dump file when completions actually changed. When they
haven't, the dump's mtime is never refreshed — so once it crossed 24 hours old it
matched `mh+24` forever, and **every** shell paid full `compinit` instead of `-C`.
The local `.zcompdump` was 18 days stale and still being re-checked on every start.

Worse, when the dump is missing entirely, full `compinit` + `compdump` costs
**3.35s** (measured via zprof: 2992ms self time in `compinit`, 806 `compdef` calls,
129ms in `compdump`). That is the occasional multi-second hang.

**Fix:** `touch` the dump after a full `compinit` so the guard resets and the next
start takes the fast path.

---

## Fixes applied

| Fix | Saving | File |
|---|---|---|
| `touch` zcompdump after full compinit — un-stick the 24h guard | ~80ms/start, avoids 3.3s cold stalls | `src/scripts/setup.programs-conf.zsh` |
| Lazy-load `thefuck` behind a self-replacing `fuck()` stub | ~68ms | `src/scripts/setup.programs-conf.zsh` |
| Cache `oh-my-posh init zsh` output, regenerate when binary/theme is newer | ~103ms | `src/installers/ohmyposh.configure.zsh` |
| `typeset -U path PATH` + drop the redundant early `export PATH` | PATH 85 → 41 entries, 0 dups | `profiles/mrsauravsahu/.zshrc` |
| Remove broken `${HOME}/${CLI_CONFIG_ROOT}/...` shims entry | — (dead path) | `profiles/mrsauravsahu/.zshrc` |
| Move macOS-only PATH/alias lines out of the cross-platform `.zshrc` | — (organization) | `profiles/mrsauravsahu/.zshrc` |

### On caching oh-my-posh

`oh-my-posh init zsh` output is deterministic **except** `POSH_SESSION_ID`, a fresh
UUID per call that keys oh-my-posh's own segment cache. Freezing it into the cached
file would make every shell share one session ID and bleed cached segments between
shells. The generated conf therefore strips that line from the cache and exports a
fresh per-shell value using fork-free zsh builtins (`$$` + `$RANDOM`).

---

## Verified after patching

- oh-my-posh prompt renders; `_omp_precmd` hook installed
- `POSH_SESSION_ID` unique per shell
- `fuck` stub correctly replaces itself with the real thefuck function on first call
- 1733 completions loaded
- PATH: 85 → 41 entries, 0 duplicates

---

## Not addressed

- **`zimfw init.zsh` (54ms)** — would need module pruning; left alone.
- **Global `/etc/zshrc` + `/etc/zprofile` (90ms)** — system files, mostly
  `path_helper`. Not ours to edit.
- **`~/.mrsauravsahu/dotfiles/darwin.zshrc`** lives in a separate repo
  (`mrsauravsahu/dotfiles`). It still duplicates 11 things from `.zshrc`
  (aliases `cat`/`ll`/`l`/`h`/`k`, the `nvim` function, ruby/dotnet PATH entries,
  both asdf `set-env` sources) and adds a second, non-existent `~/.asdf/shims`.
  Deduping it was deliberately deferred.

---

## ⚠️ Requires a paired dotfiles PR

`darwin.zshrc` is sourced from the **middle** of `.zshrc`, so for anything defined
in both files, whichever defines it *later* silently wins. Both files defined
`colima_start` with **different flags**, and `.zshrc` defined it after the source —
so the `.zshrc` version won and the effective alias never had `--with-kubernetes`.

Removing that duplicate here would have silently flipped Kubernetes **on**. To keep
behavior identical, a paired change drops the flag in `darwin.zshrc`:

- branch: `colima-no-kubernetes` in `mrsauravsahu/dotfiles` (commit `68d77dc`)
- PR: https://github.com/mrsauravsahu/dotfiles/pull/new/colima-no-kubernetes

**Merge the dotfiles PR together with this one.** Verified: with both applied, the
effective `colima_start` is byte-identical to today's.
