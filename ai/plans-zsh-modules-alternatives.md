# Plan: Add zimfw alongside Antigen (with Antigen fallback)

## Context

The current setup uses Antigen (v2.2.2) to manage zsh plugins. Antigen is slow at shell startup, has known quirks (e.g., the `ptavares/zsh-direnv@main` branch workaround), and is unmaintained. zimfw is one of the fastest alternatives — it generates a static init script at install time so no runtime plugin resolution happens on shell start. The goal is to add zimfw as the primary plugin manager while keeping the existing antigen config working as a fallback, so the switch is reversible.

## Plugin Mapping: Antigen → zimfw

| Antigen | zimfw equivalent | Notes |
|---------|-----------------|-------|
| `antigen bundle qoomon/zsh-lazyload` | `zmodule qoomon/zsh-lazyload` | Direct GitHub repo — identical |
| `antigen bundle ptavares/zsh-direnv@main` | `zmodule ptavares/zsh-direnv` | zimfw reads default branch automatically; `@main` workaround not needed |
| `antigen bundle autojump` | `zmodule ohmyzsh/ohmyzsh --root plugins/autojump` | OMZ plugin — requires `autojump` installed via Homebrew (`brew install autojump`) |
| `antigen bundle zsh-users/zsh-syntax-highlighting` | `zmodule zsh-users/zsh-syntax-highlighting` | Direct GitHub repo — identical |
| `antigen bundle ohmyzsh/ohmyzsh plugins/git` | `zmodule ohmyzsh/ohmyzsh --root plugins/git` | OMZ plugin — `--root` flag selects subdirectory (zimfw v1.10.0+) |
| `# antigen bundle zsh-users/zsh-autosuggestions` | `# zmodule zsh-users/zsh-autosuggestions` | Keep commented out — same macOS caveat applies |

## Chosen Alternative: zimfw

- **Why fastest**: generates a static `init.zsh` at install/update time; shell startup just `source`s it — no runtime git or plugin resolution
- **OMZ plugin support**: native via `zmodule ohmyzsh/ohmyzsh --root plugins/<name>` (v1.10.0+)
- **Easy updates**: `zimfw upgrade` (self) + `zimfw update` (plugins)
- **Config syntax**: close to antigen — one module declaration per line in `.zimrc`

## Strategy: Additive, Non-Destructive

- **Keep** `current/conf/antigen.conf.sh` and all antigen tooling untouched
- **Add** `current/conf/zimfw.conf.zsh` — new conf file loaded by the existing `programs.conf.zsh` loop
- The loop in `programs.conf.zsh` sources files alphabetically; `antigen.conf.sh` sorts before `zimfw.conf.zsh`, so we guard against double-loading with a flag variable
- **Add** `src/installers/zimfw.install.zsh` — mirrors pattern of `antigen.install.zsh`

## Implementation Plan

### 1. Create `src/installers/zimfw.install.zsh`

```zsh
if [ -f "$CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh" ]; then
  Log 'Seems zimfw is already installed!'
else
  Log "Installing zimfw plugin manager"
  curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh \
    -o $CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh
fi
```

Mirrors the pattern of `antigen.install.zsh` (check → skip or download).

### 2. Create `current/conf/zimfw.conf.zsh`

```zsh
# Skip if antigen already loaded plugins (fallback mode)
[[ -n "$ANTIGEN_LOADED" ]] && return

export ZIMFW_HOME=${CLI_CONFIG_ROOT}/current/zimfw
export ZIM_CONFIG_FILE=${CLI_CONFIG_ROOT}/current/conf/.zimrc
export ZIM_HOME=$ZIMFW_HOME

source "${CLI_CONFIG_TOOLS_LOCATION}/zimfw.zsh" 2>/dev/null || return

zmodule qoomon/zsh-lazyload
zmodule ptavares/zsh-direnv
zmodule ohmyzsh/ohmyzsh --root plugins/autojump
zmodule zsh-users/zsh-syntax-highlighting
# zmodule zsh-users/zsh-autosuggestions   # re-enable if desired
zmodule ohmyzsh/ohmyzsh --root plugins/git

zimfw install 2>/dev/null
source "${ZIMFW_HOME}/init.zsh"
```

### 3. Update `current/conf/antigen.conf.sh` (minimal change — add sentinel)

Add one line at the end of the existing antigen config to set a flag so zimfw.conf.zsh skips itself:

```zsh
# ... existing antigen lines unchanged ...
antigen apply
export ANTIGEN_LOADED=1   # ← add this line only
```

This is the only change to existing antigen files.

### 4. Create `current/conf/.zimrc`

zimfw reads its module list from `ZIM_CONFIG_FILE`. This file mirrors the `zmodule` declarations from step 2 (zimfw needs it to exist as a static file for `zimfw install`/`zimfw update` to work):

```
zmodule qoomon/zsh-lazyload
zmodule ptavares/zsh-direnv
zmodule ohmyzsh/ohmyzsh --root plugins/autojump
zmodule zsh-users/zsh-syntax-highlighting
zmodule ohmyzsh/ohmyzsh --root plugins/git
```

## Critical Files

| File | Action |
|------|--------|
| `src/installers/zimfw.install.zsh` | Create |
| `current/conf/zimfw.conf.zsh` | Create |
| `current/conf/.zimrc` | Create |
| `current/conf/antigen.conf.sh` | Minimal edit — add `export ANTIGEN_LOADED=1` at end |
| `current/tools/antigen.zsh` | No change |
| `current/programs.conf.zsh` | No change |

## Fallback Behavior

- If `zimfw.zsh` is not installed (e.g., on a fresh machine that ran the antigen installer but not the zimfw installer), `source zimfw.zsh` fails silently (`2>/dev/null || return`) and antigen takes over
- To deliberately fall back to antigen: remove or rename `current/tools/zimfw.zsh`
- To permanently switch: remove `current/conf/antigen.conf.sh` once zimfw is confirmed working

## Verification

1. Run the zimfw installer: `source src/installers/zimfw.install.zsh`
2. Open a new shell — confirm zimfw loads plugins (git aliases, `j` autojump, syntax highlighting)
3. Measure startup: `time zsh -i -c exit` — compare before/after
4. Test fallback: temporarily rename `current/tools/zimfw.zsh` and open a new shell — antigen should take over
5. Update all plugins: `zimfw update && zimfw upgrade`
