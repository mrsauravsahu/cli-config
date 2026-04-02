# vim: set filetype=zsh :
# zmodload zsh/zprof

DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Smarter completion initialization
#autoload -Uz compinit
#if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
#    compinit
#else
#    compinit -C
#fi

# add to PATH  
PATH_PREFIX=''

GDK_SCALE=2
PATH_PREFIX="${PATH_PREFIX}:/opt/homebrew/bin"

# add dotfiles script to the path
if [ -d "${HOME}/.mrsauravsahu/dotfiles/" ]; then
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/.mrsauravsahu/dotfiles/scripts"
  . ${HOME}/.mrsauravsahu/dotfiles/${currentOs}.zshrc 2> /dev/null || true
fi

# add friday scripts to the path
if [ -d "${HOME}/GenAI/code/friday/scripts" ]; then
  PATH_PREFIX="${PATH_PREFIX}:${HOME}/GenAI/code/friday/scripts"
fi

# case insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

currentOs=`uname -s | tr 'A-Z' 'a-z'`

CLI_CONFIG_ROOT=$(ls -la ~/.zshrc | sed "s/^.*\->//" | awk -F '/' 'NF{NF-=3}1' 'OFS=/' | xargs)
CLI_CONFIG_THEME='atomic'

XARGS_OPTIONS=$(if [ "${currentOs}" = "linux" ]; then echo '--no-run-if-empty'; else echo ''; fi)

# cleanup old zsh compiled files
# find ${CLI_CONFIG_ROOT}/current -maxdepth 2 -type f -regex '.*zwc$' | xargs ${XARGS_OPTIONS} rm

# loads cli-config env variables
. $CLI_CONFIG_ROOT/src/scripts/env.zsh

# runs the configuration for all installed programs
. $CLI_CONFIG_PROGRAMS_CONF

SAVEHIST=100000  # Save most-recent 100000 lines
HISTFILE=~/.zsh_history

alias cat=bat
alias ll='ls -l'
alias l='ls'
alias h=helm
alias k=kubectl

PATH_PREFIX="${PATH_PREFIX}:/Users/Saurav_Sahu/.dotnet/tools"
PATH_PREFIX="${PATH_PREFIX}:/opt/homebrew/opt/ruby@3.2/bin"
PATH_PREFIX="${PATH_PREFIX}:/opt/homebrew/lib/ruby/gems/3.2.0/bin"
PATH_PREFIX="${PATH_PREFIX}:${CLI_CONFIG_ROOT}/current/path"

alias colima_start='colima start --mount-type virtiofs --cpu 12 --memory 20 --disk 256 --vm-type vz --vz-rosetta'

PATH_PREFIX="$HOME/.asdf/shims:${PATH_PREFIX}"
. ~/.asdf/plugins/dotnet/set-dotnet-env.zsh
. ~/.asdf/plugins/golang/set-env.zsh

alias vim=nvim
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

SESSION_NAME="${PWD//\./_}"
if [[ "$(tmux has-session -s "${SESSION_NAME}" 2>/dev/null ; echo $?)" -eq 0 ]]; then
  tmux attach-session -t "${SESSION_NAME}" || true
else
  tmux new-session -s "${SESSION_NAME}" -c "${PWD}"
  tmux attach-session -t "${SESSION_NAME}"
fi

export PATH="${PATH_PREFIX}:${PATH}"

# zprof

