# Plan: Shell Startup Further Optimization

**Baseline:** post-zimfw migration — wall time ~1.1s (down from ~9.7s)  
**Goal:** push wall time under 500ms by eliminating the remaining high-cost items

---

## Current hot spots (zimfw zprof)

| Rank | Function | Self (ms) | Self % |
|------|----------|-----------|--------|
| 1 | `compinit` | 237 | 48.7% |
| 2 | `antigen` (residual) | 80 | 16.6% |
| 3 | `compdef` | 63 | 13.0% |
| 4 | `compdump` | 55 | 11.3% |
| 5 | `compaudit` | 20 | 4.2% |
| 6 | `_zsh_direnv_load` | 16 | 3.4% |
| 7 | `_zsh_highlight_load_highlighters` | 10 | 2.1% |

`compinit` + its callees (`compdef`, `compdump`, `compaudit`) account for **~375ms / 77%** of all tracked time.  
The `antigen` residual (80ms) signals that zsh-autosuggestions is still loading from the old antigen bundle path.

---

## Fix 1 — Cache `compinit` (skip rebuild when dump is < 24h old)

**Estimated saving: 200–375ms**

`compinit` regenerates `~/.zcompdump` unconditionally on every shell. The dump is valid until new completions are installed.

Replace the unconditional call in `src/scripts/setup.programs-conf.zsh`:

```zsh
# Before
echo 'autoload -Uz compinit && compinit' >> $CLI_CONFIG_PROGRAMS_CONF

# After
cat >> $CLI_CONFIG_PROGRAMS_CONF << 'EOF'
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
EOF
```

`-C` skips the security audit and dump regeneration when the dump is fresh. This eliminates `compaudit`, `compdump`, and most `compdef` time on every shell except the first one after 24 hours.

---

## Fix 2 — Purge residual antigen path from zsh-autosuggestions

**Estimated saving: 80ms**

`zprof` shows `antigen` still appearing at rank 2. The zsh-autosuggestions bundle is still being sourced from `current/antigen/bundles/zsh-users/zsh-autosuggestions/`. This happens because:

1. `antigen.conf.sh` may still be included in `programs.conf.zsh` (guard on `CLI_CONFIG_MODULES` not yet regenerated), **or**
2. zimfw's `init.zsh` is sourcing the autosuggestions plugin from antigen's cache path.

**Steps:**
1. Run `cli-config configure && cli-config install` to regenerate `programs.conf.zsh` with `CLI_CONFIG_MODULES=zimfw` — ensures `antigen.conf.sh` is excluded.
2. Verify zimfw's `init.zsh` loads autosuggestions from its own path (`current/zimfw/…`), not `current/antigen/…`.
3. Delete `current/antigen/` if it is no longer referenced: `rm -rf $CLI_CONFIG_ROOT/current/antigen`.

---

## Fix 3 — Lazy-load `thefuck`

**Estimated saving: 100–300ms** (not yet visible in zprof because thefuck spawns Python *after* zsh init)

`setup.programs-conf.zsh` writes `eval $(thefuck --alias)` into `programs.conf.zsh`. This forks a Python process on every shell.

```zsh
# Replace in setup.programs-conf.zsh:
echo 'eval $(thefuck --alias)' >> $CLI_CONFIG_PROGRAMS_CONF

# With:
cat >> $CLI_CONFIG_PROGRAMS_CONF << 'EOF'
fuck() {
  unfunction fuck
  eval "$(thefuck --alias)"
  fuck "$@"
}
EOF
```

---

## Fix 4 — Lazy-load `pyenv init`

**Estimated saving: 100–200ms** (similarly external to zprof — pyenv forks happen after shell functions are set)

`current/conf/pyenv.conf.sh` runs `eval "$(pyenv init -)"` and `eval "$(pyenv virtualenv-init -)"` on every shell.

```zsh
# In pyenv.configure.zsh, replace the eval lines with:
cat >> $CONF << 'EOF'
export PYENV_ROOT="${CLI_CONFIG_ROOT}/current/pyenv"
export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"

pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  eval "$(command pyenv virtualenv-init -)"
  pyenv "$@"
}
EOF
```

Shims cover day-to-day `python`/`pip` use. Full init is deferred until `pyenv` is called explicitly.

---

## Fix 5 — Cache `oh-my-posh init` output

**Estimated saving: 30–80ms**

`current/conf/ohmyposh.conf.sh` forks the `oh-my-posh` binary on every shell to generate the same zsh init script. The output is deterministic for a given theme.

```zsh
# In ohmyposh.configure.zsh, write a loader instead of a direct eval:
cat >> $CONF << 'EOF'
_OMP_CACHE="${CLI_CONFIG_ROOT}/current/ohmyposh/.init.cache.zsh"
_OMP_THEME_MARKER="${CLI_CONFIG_ROOT}/current/ohmyposh/.current_theme"
if [[ ! -f "$_OMP_CACHE" || "$(cat $_OMP_THEME_MARKER 2>/dev/null)" != "$CLI_CONFIG_THEME" ]]; then
  "$CLI_CONFIG_ROOT/current/ohmyposh/oh-my-posh" init zsh \
    --config "$CLI_CONFIG_ROOT/current/ohmyposh/themes/$CLI_CONFIG_THEME.omp.json" \
    > "$_OMP_CACHE"
  echo "$CLI_CONFIG_THEME" > "$_OMP_THEME_MARKER"
fi
source "$_OMP_CACHE"
unset _OMP_CACHE _OMP_THEME_MARKER
EOF
```

The cache is invalidated only when `CLI_CONFIG_THEME` changes.

---

## Fix 6 — Re-enable `nvm` lazy-load

**Estimated saving: 30–100ms**

`current/conf/nvm.conf.sh` adds `$NVM_DIR` to PATH but never sources `nvm.sh`, so the `nvm` command is unavailable. The lazy-load line in `nvm.configure.zsh` is commented out.

```zsh
# In nvm.configure.zsh, replace the commented line with:
printf 'lazyload nvm node npm -- "source $NVM_DIR/nvm.sh"\n' >> $CONF
```

---

## Fix 7 — Native `CLI_CONFIG_ROOT` detection (no forks)

**Estimated saving: 2–10ms**

Both zshrc profiles resolve `CLI_CONFIG_ROOT` by forking `ls`, `sed`, `awk`, and `xargs`:

```zsh
CLI_CONFIG_ROOT=$(ls -la ~/.zshrc | sed "s/^.*\->//" | awk -F '/' 'NF{NF-=3}1' 'OFS=/' | xargs)
```

Replace with zsh's native symlink resolution:

```zsh
CLI_CONFIG_ROOT="${${${:-~/.zshrc}:A:h}:h:h}"
```

`${...:A}` resolves symlinks in-process; `:h` strips the last path component.

---

## Fix 8 — Remove `.zwc` cleanup from default `.zshrc`

**Estimated saving: 5–20ms + fork cost**

`profiles/default/.zshrc` runs on every shell:

```zsh
find ${CLI_CONFIG_ROOT}/current -maxdepth 2 -type f -regex '.*zwc$' | xargs ${XARGS_OPTIONS} rm
```

This is a one-time install-time cleanup. Move it to `src/defs/install.zsh` and remove it from `profiles/default/.zshrc`.

---

## Priority order

| # | Fix | Est. saving | Effort | Dependency |
|---|-----|-------------|--------|------------|
| 1 | Cache `compinit` | 200–375ms | Low | none |
| 2 | Purge antigen residual | 80ms | Low | regenerate conf |
| 3 | Lazy-load `thefuck` | 100–300ms | Low | none |
| 4 | Lazy-load `pyenv init` | 100–200ms | Low | none |
| 5 | Cache `oh-my-posh init` | 30–80ms | Low | none |
| 6 | Re-enable `nvm` lazy-load | 30–100ms | Trivial | none |
| 7 | Native `CLI_CONFIG_ROOT` | 2–10ms | Low | none |
| 8 | Remove `.zwc` cleanup | 5–20ms | Trivial | none |

Fixes 1–2 alone should bring wall time from ~1.1s to ~600–700ms. All eight together should reach **< 400ms**.

---

## Measuring

Enable zprof in `profiles/mrsauravsahu/.zshrc`:
- Uncomment `zmodload zsh/zprof` (line 3)
- Uncomment `zprof` (line 132)

Wall time: `time zsh -i -c exit`

Capture before and after each fix. Record results in `results.md`.
