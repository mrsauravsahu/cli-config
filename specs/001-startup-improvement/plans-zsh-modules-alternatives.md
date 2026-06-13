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

## Current State (as of 2026-06-13)

Antigen is **currently active**. Baseline startup cost: **~9.7s wall time**, with antigen's internal WARN/LOG/TRACE calls consuming ~95% of tracked function time (see `baseline-zprof.txt`).

## Strategy: `CLI_CONFIG_MODULES` setting

Rather than relying on alphabetical conf file sort order, a `CLI_CONFIG_MODULES` variable selects which plugin manager loads. Both conf files exist side-by-side; each one checks the variable and skips itself if not selected.

Set in `.zshrc` (or `env.zsh`) before `programs.conf.zsh` is sourced:

```zsh
export CLI_CONFIG_MODULES=zimfw   # or: antigen
```

Default (unset) falls back to `antigen` so existing machines are unaffected until explicitly opted in.

- **Add** `src/installers/zimfw.install.zsh` — mirrors pattern of `antigen.install.zsh`

## How cli-config install/configure works

`cli-config install` (and `configure`) loops over `CCOPT_TOOLS` and runs:
```
src/installers/<tool>.install.zsh
src/installers/<tool>.configure.zsh
```
The default tool list is hardcoded in `src/utils/read-options.zsh` line 6:
```zsh
CCOPT_TOOLS=('antigen' 'ohmyposh' 'nvm' 'pyenv' 'dotnet' 'tfenv' 'gvm')
```
A tool is also selectable via `-t zimfw` (validated against files present in `src/installers/`). After all tools run, `src/scripts/setup.programs-conf.zsh` assembles `current/programs.conf.zsh`.

The configure script for each tool writes a conf file into `current/conf/` — that's where `antigen.configure.zsh` writes `antigen.conf.sh` today. The `CLI_CONFIG_MODULES` guard must therefore live inside the **generated conf file**, written by the configure script, not hardcoded by hand.

## Implementation Plan

### Step 1 — Create `src/installers/zimfw.install.zsh`

Downloads `zimfw.zsh` into `$CLI_CONFIG_TOOLS_LOCATION`, same pattern as `antigen.install.zsh`:

```zsh
if [ -f "$CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh" ]; then
  Log 'Seems zimfw is already installed!'
else
  Log "Installing zimfw plugin manager"
  curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh \
    -o $CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh
  mkdir -p $CLI_CONFIG_ROOT/current/zimfw 2>/dev/null
fi
```

### Step 2 — Create `src/installers/zimfw.configure.zsh`

Writes `current/conf/zimfw.conf.zsh` and `current/conf/.zimrc`, mirroring `antigen.configure.zsh`:

```zsh
TOOL=zimfw
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.zsh
ZIMRC=$CLI_CONFIG_CONF_LOCATION/.zimrc

# Write .zimrc (module list — used by zimfw install/update)
tee $ZIMRC >/dev/null <<'EOF'
zmodule qoomon/zsh-lazyload
zmodule ptavares/zsh-direnv
zmodule ohmyzsh/ohmyzsh --root plugins/autojump
zmodule zsh-users/zsh-syntax-highlighting
zmodule ohmyzsh/ohmyzsh --root plugins/git
EOF

# Write conf file
echo -n >$CONF
tee $CONF >/dev/null <<EOF
[[ "\${CLI_CONFIG_MODULES:-antigen}" != "zimfw" ]] && return

export ZIMFW_HOME=\${CLI_CONFIG_ROOT}/current/zimfw
export ZIM_CONFIG_FILE=\${CLI_CONFIG_CONF_LOCATION}/.zimrc
export ZIM_HOME=\$ZIMFW_HOME

source "\${CLI_CONFIG_TOOLS_LOCATION}/zimfw.zsh" 2>/dev/null || return

zimfw install -q 2>/dev/null
source "\${ZIMFW_HOME}/init.zsh"
EOF
```

### Step 3 — Update `src/installers/antigen.configure.zsh`

Prepend the `CLI_CONFIG_MODULES` guard to the generated conf. Change the `tee $CONF` heredoc to add one line at the top:

```zsh
tee $CONF >/dev/null <<EOF
[[ "\${CLI_CONFIG_MODULES:-antigen}" != "antigen" ]] && return

ADOTDIR=\${CLI_CONFIG_ROOT}/current/antigen
# ... rest unchanged ...
EOF
```

### Step 4 — Add `zimfw` to the default tool list in `src/utils/read-options.zsh`

Replace:
```zsh
CCOPT_TOOLS=('antigen' 'ohmyposh' 'nvm' 'pyenv' 'dotnet' 'tfenv' 'gvm')
```
With:
```zsh
CCOPT_TOOLS=('antigen' 'zimfw' 'ohmyposh' 'nvm' 'pyenv' 'dotnet' 'tfenv' 'gvm')
```

Both `antigen` and `zimfw` install on every `cli-config install` run. `CLI_CONFIG_MODULES` controls which one activates at shell startup.

### Step 5 — Set `CLI_CONFIG_MODULES` in the profile

In `profiles/mrsauravsahu/.zshrc`, before the line that sources `$CLI_CONFIG_PROGRAMS_CONF`:

```zsh
export CLI_CONFIG_MODULES=zimfw   # set to 'antigen' to revert
```

### Step 6 — Re-run configure (or install) to regenerate conf files

```zsh
cli-config configure   # regenerates current/conf/ from all configure scripts
```

This writes both `antigen.conf.sh` (with guard) and `zimfw.conf.zsh` + `.zimrc` in one step.

## Critical Files

| File | Action |
|------|--------|
| `src/installers/zimfw.install.zsh` | Create |
| `src/installers/zimfw.configure.zsh` | Create |
| `src/installers/antigen.configure.zsh` | Add `CLI_CONFIG_MODULES` guard to generated conf |
| `src/utils/read-options.zsh` | Add `zimfw` to default `CCOPT_TOOLS` list |
| `profiles/mrsauravsahu/.zshrc` | Add `export CLI_CONFIG_MODULES=zimfw` before programs.conf source |
| `current/conf/antigen.conf.sh` | Regenerated by configure — no manual edit |
| `current/conf/zimfw.conf.zsh` | Generated by configure — do not edit by hand |
| `current/conf/.zimrc` | Generated by configure — do not edit by hand |

## Switching Between Managers

| Goal | Action |
|------|--------|
| Use zimfw | Set `CLI_CONFIG_MODULES=zimfw` in `.zshrc` |
| Revert to antigen | Set `CLI_CONFIG_MODULES=antigen` (or unset) in `.zshrc` |
| Fresh machine (zimfw not installed) | Leave unset — antigen runs by default |
| Update zimfw plugins | `zimfw update && zimfw upgrade` |

## Verification

1. Run `cli-config configure` (or `cli-config install`) to regenerate conf files
2. Set `CLI_CONFIG_MODULES=zimfw` in `.zshrc`
3. Open a new shell — confirm git aliases, `j` (autojump), syntax highlighting all work
4. Confirm antigen did NOT run: `type antigen` should show `antigen not found`
5. Measure startup: `time zsh -i -c exit` — compare against baseline in `baseline-zprof.txt` (~9.7s)
6. Test revert: set `CLI_CONFIG_MODULES=antigen` in `.zshrc`, open new shell — antigen loads again
