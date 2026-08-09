ANTIGEN_LOG=false
# vim: set filetype=zsh :
# zmodload zsh/zprof
HOMEBREW_NO_AUTO_UPDATE=1

currentOs=`uname -s | tr 'A-Z' 'a-z'`
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_COMPFIX="true"

CLI_CONFIG_ROOT=${${$(readlink ~/.zshrc):A}:h:h:h}
CLI_CONFIG_MODULES=zimfw
CLI_CONFIG_THEME=takuya
XARGS_OPTIONS=$(if [ "${currentOs}" = "linux" ]; then echo '--no-run-if-empty'; else echo ''; fi)

# This will hold all changes to PATH
# Add homebrew
PATH_PREFIX="/opt/homebrew/bin"

# Keep PATH/path free of duplicates. PATH_PREFIX is prepended again at the end of
# this file, so exporting it here too is what put homebrew (and everything else)
# on PATH twice.
typeset -U path PATH

# add friday scripts to the path
if [ -d "${HOME}/GenAI/code/friday/scripts" ]; then
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/GenAI/code/friday/scripts"
fi

# add GenAI-Workspace scripts (gw, gw-pick) to the path
if [ -d "${HOME}/GenAI-Workspace" ]; then
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/GenAI-Workspace/scripts"
  # gw / gw-pick are scripts in ~/GenAI-Workspace/scripts (on PATH) so the tmux
  # `+g popup (a non-interactive shell) can call them too. Usage: gw [dir] [ai].
  compdef _directories gw 2>/dev/null
fi

# case insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# loads cli-config env variables
. $CLI_CONFIG_ROOT/src/scripts/env.zsh

# runs the configuration for all installed programs
. $CLI_CONFIG_PROGRAMS_CONF

# add dotfiles script to the path
if [ -d "${HOME}/.mrsauravsahu/dotfiles/" ]; then
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/.mrsauravsahu/dotfiles/scripts"
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/.mrsauravsahu/bin"
  . ${HOME}/.mrsauravsahu/dotfiles/${currentOs}.zshrc 2> /dev/null || true
  . ${HOME}/.mrsauravsahu/dotfiles/secret.${currentOs}.zshrc 2> /dev/null || true
fi

SAVEHIST=100000  # Save most-recent 100000 lines
HISTFILE=~/.zsh_history

alias cls=clear
alias cat=bat
alias ll='ls -l'
alias l='ls'
alias h=helm
alias k=kubectl

# macOS-only entries (colima, homebrew ruby@3.2, ~/.dotnet/tools) live in
# ~/.mrsauravsahu/dotfiles/darwin.zshrc - this file is the cross-platform base.
PATH_PREFIX="${PATH_PREFIX}:${CLI_CONFIG_ROOT}/current/path"
PATH_PREFIX="${CLI_CONFIG_ROOT}/current/asdf/shims:${PATH_PREFIX}"

# if [ -d "$HOME/.cargo/env" ]; then
#   . "$HOME/.cargo/env"
# fi

if [ -d "${CLI_CONFIG_ROOT}/current/asdf" ]; then
  # (dropped a "${HOME}/${CLI_CONFIG_ROOT}/..." entry here - CLI_CONFIG_ROOT is
  # already absolute, so it expanded to /Users/<user>//Users/<user>/... and never
  # existed. The correct shims dir is already prepended above.)
  . ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh
  . ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/dotnet/set-dotnet-env.zsh
fi

function nvim() {
  if [[ "$#" -eq 0 ]]; then 
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim .
  elif [[ -d "$1" ]]; then
   pushd "$1" > /dev/null
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim $1
   popd > /dev/null
  else
   CLI_CONFIG_ROOT="${CLI_CONFIG_ROOT}" env nvim --cmd ":e $1"
  fi
}

auto_tmux() {
  # Only run in interactive shells
  [[ $- != *i* ]] && return

  local in_vim=false
  [[ -n "$NVIM" || -n "$VIM" ]] && in_vim=true

  local level="${TMUX_NESTING_LEVEL:-0}"
  local session_name="${PWD//[\.\-\/]/_}"

  # Case: not in vim, not in tmux → attach or create outer session
  if [[ "$in_vim" == false && -z "$TMUX" ]]; then
    export TMUX_NESTING_LEVEL=1
    exec tmux new-session -As "${session_name}"
  fi

  # Case: not in vim, already in tmux → normal pane/split, do nothing
  if [[ "$in_vim" == false ]]; then
    return
  fi

  # Case: in vim terminal, already at max nesting depth → do nothing
  # Covers: new pane inside vim-nested tmux (level=2, $NVIM still inherited)
  if (( level <= 1 )); then
  # Case: in vim terminal (nvterm), not yet at max depth → attach or create nested session
  # Handles both: vim outside tmux (TMUX unset) and vim inside outer tmux (TMUX set).
  # The level guard above prevents runaway nesting.
     TMUX_NESTING_LEVEL="$(( level + 1 ))" tmux -L vim new-session -As "${session_name}" && exit
  fi
}

auto_tmux

# Auto-rename tmux window based on running command
# only set up hooks when inside a tmux session
if [[ -n "$TMUX" ]]; then
  _tmux_title() {
    # extract just the command name, strip arguments
    local cmd="${1%% *}"
    # give editors a richer title showing the file/dir
    if [[ "$cmd" == "nvim" || "$cmd" == "vim" ]]; then
      # strip command name and leading space to isolate the first argument
      local arg="${1#"$cmd"}"
      arg="${arg# }"
      # use cwd when: no arg given, or arg is a shorthand for the current/home dir
      if [[ -z "$arg" || "$arg" == "." || "$arg" == "./" || "$arg" == "~" || "$arg" == "~/" ]]; then
        arg="$(basename "$PWD")"
      else
        arg="$(basename "$arg")"
      fi
      # set window title to "nvim//<filename>" (tmux 3.7+ rejects ':' and '.' in window names)
      tmux rename-window "nvim//${arg}"
    else
      # for all other commands, use the command name
      tmux rename-window "$cmd"
      fi
    }
  # rename window as each command starts
  preexec() { _tmux_title "$1" }
  # reset window title back to "zsh" after command finishes
  precmd() { tmux rename-window "zsh" }
fi

export PATH="${PATH_PREFIX}:${PATH}"
# zprof

