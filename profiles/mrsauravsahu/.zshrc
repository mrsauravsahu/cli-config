# vim: set filetype=sh :
# zmodload zsh/zprof

DISABLE_AUTO_UPDATE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_COMPFIX="true"

# Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

GDK_SCALE=2
export PATH="${PATH}:/opt/homebrew/bin"

# add dotfiles script to the path
if [ -d "${HOME}/.mrsauravsahu/dotfiles/scripts" ]; then
  export PATH="${PATH}:${HOME}/.mrsauravsahu/dotfiles/scripts"
fi

# add friday scripts to the path
if [ -d "${HOME}/GenAI/code/friday/scripts" ]; then
  export PATH="${PATH}:${HOME}/GenAI/code/friday/scripts"
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

# create a secret.linux.zshrc or secret.darwin.zshrc to run your customizations
. ${CLI_CONFIG_ROOT}/profiles/mrsauravsahu/${currentOs}.zshrc 2> /dev/null || true
. ${CLI_CONFIG_ROOT}/profiles/mrsauravsahu/secret.${currentOs}.zshrc 2> /dev/null || true

SAVEHIST=100000  # Save most-recent 100000 lines
HISTFILE=~/.zsh_history

alias cat=bat
alias ll='ls -l'
alias l='ls'
alias h=helm
alias k=kubectl
alias work="code --user-data-dir '/Users/Saurav_Sahu/.config/vscode-manager/work/data' --extensions-dir '/Users/Saurav_Sahu/.config/vscode-manager/work/extensions'"

export PATH="${PATH}:/Users/Saurav_Sahu/.dotnet/tools"
export PATH="${PATH}:/opt/homebrew/opt/ruby@3.2/bin"
export PATH="${PATH}:/opt/homebrew/lib/ruby/gems/3.2.0/bin"
export PATH="${PATH}:${CLI_CONFIG_ROOT}/current/path"

alias http-server='npx files-upload-server /Users/Saurav_Sahu/Desktop/local-http-server/'
alias colima_start='colima start --mount-type virtiofs --cpu 12 --memory 20 --disk 256 --vm-type vz --vz-rosetta'
alias colima_start_k8s='colima start --mount-type virtiofs --cpu 12 --memory 20 --disk 256 --with-kubernetes --vm-type vz --vz-rosetta'
alias vim=nvim

. "$HOME/.cargo/env"

export PATH="$HOME/.asdf/shims:${PATH}"
. ~/.asdf/plugins/dotnet/set-dotnet-env.zsh
. ~/.asdf/plugins/golang/set-env.zsh

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

# zprof

# if not in a Tmux session, start one
# if [[ -z "$TMUX" ]]; then 
#   exec tmux -u
# else
#   TMUX_SESSION_NAME="${PWD}"
#   tmux new-session -s "${TMUX_SESSION_NAME}" -c "${PWD}" -f "${XDG_CONFIG_HOME}/tmux/tmux.conf"
# fi

