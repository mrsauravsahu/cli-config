#!/usr/bin/env zsh

. ${CLI_CONFIG_ROOT}/src/utils/log.zsh

configure() {
  # Create installation folder if not exists
  if [ ! -d "${CLI_CONFIG_ROOT}/current" ]; then
    Log ": Please run cli-config in 'install' mode first to update configuration."
    exit
  fi

  # load cli-config env variables
  . ${CLI_CONFIG_ROOT}/src/scripts/env.zsh

  programs=('asdf' 'zimfw' 'ohmyzsh' 'ohmyposh' 'nvm' 'pyenv' 'dotnet' 'tfenv' 'gvm' 'zsh-plugins')
  for item in ${programs[@]}; do
    Log "Updating configuration for cli-config/${item}"
    if [ -d "${CLI_CONFIG_ROOT}/current/${item}" ]; then
      . ${CLI_CONFIG_ROOT}/src/installers/${item}.configure.zsh
    fi
  done
  . ${CLI_CONFIG_ROOT}/src/scripts/setup.programs-conf.zsh

  echo "Configuration updated!"
}
