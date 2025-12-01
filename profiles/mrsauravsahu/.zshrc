DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Smarter completion initialization
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# zmodload zsh/zprof

export PATH="${PATH}:/opt/homebrew/bin"

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
# this file will be ignored in source control
. ${CLI_CONFIG_ROOT}/profiles/default/secret.${currentOs}.zshrc 2> /dev/null || true

SAVEHIST=100000  # Save most-recent 100000 lines
HISTFILE=~/.zsh_history

# zprof
