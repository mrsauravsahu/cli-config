# Plan: Auto-tmux with Vim Terminal Nesting

## Context

The user wants `.zshrc` to auto-launch tmux when a terminal opens, but also support a **second level** of nested tmux inside vim's built-in terminal (`:terminal`). The hard part is preventing uncontrolled nesting (every new tmux pane would re-trigger the auto-launch) while deliberately allowing exactly one nested level inside vim.

---

## Edge Cases

| Situation | `$TMUX` set? | In vim terminal? | Desired action |
|---|---|---|---|
| Fresh terminal, no tmux running | No | No | Create new outer session |
| Fresh terminal, session exists | No | No | Attach to existing session |
| New pane/split inside outer tmux | Yes | No | Do nothing (already in tmux) |
| Vim terminal, vim launched outside tmux | No | Yes | Start a nested tmux (level 1) |
| Vim terminal, vim launched inside outer tmux | Yes | Yes | Start a nested tmux (level 2) |
| Pane inside the vim-nested tmux | Yes | Yes | Do nothing (already in nested) |

**Key insight**: `$TMUX` alone is not enough to gate — we need to distinguish "already in outer tmux pane" (don't nest) from "in vim's terminal which is inside outer tmux" (do nest).

---

## Detection Strategy

- **Vim detection**: Vim sets `$VIM` (vim) and `$NVIM` (neovim) in child processes of its `:terminal`. These are reliable signals. (`$NVIM_LISTEN_ADDRESS` is not set in newer Neovim versions.)
- **Nesting depth**: Use a custom env var `TMUX_NESTING_LEVEL` (0, 1, or 2) that we export when starting each level, so every subsequent shell knows its depth.
- **Named socket for nested tmux**: Run the vim-level tmux on a separate socket (`tmux -L vim`) so it doesn't interfere with or accidentally attach to the outer session list.
- **Session name from PWD**: Derive the nested session name from the working directory (`${PWD//[\.\-\/]/_}`) so that multiple nvterm windows opened from the same directory all attach to the *same* nested session rather than spawning new ones.

---

## Key Binding Note (tmux.conf concern, not .zshrc)

When nested, both tmux instances capture `Ctrl+b`. Standard solution — add to `~/.tmux.conf`:

```tmux
# Press Ctrl+b twice to send prefix to inner tmux
bind-key -n C-b send-prefix
```

Or set a different prefix for the vim-socket tmux via a separate config loaded with `-f`.

---

## Files to Modify

- `~/.zshrc` — add the `auto_tmux` function and call it
- `~/.tmux.conf` (optional but recommended) — add pass-through binding for nested prefix

---

## Verification

1. Open a fresh terminal → should land inside tmux session `main`
2. Open a new tmux pane (`Ctrl+b c`) → should NOT nest, just a normal shell
3. Open nvim inside tmux, open nvterm → nested tmux starts on the `vim` socket, session named after `$PWD`
4. Open a second nvterm from the same directory → attaches to the same nested session (not a new one)
5. Create a split inside the vim-nested tmux → works independently
6. Open nvterm again while already inside the vim-nested tmux → does nothing (level=2 guard fires)
7. Open nvim *outside* tmux, open nvterm → nested tmux starts at level 1

