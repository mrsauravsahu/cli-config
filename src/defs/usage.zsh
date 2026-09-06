#!/usr/bin/env bash

. ${CLI_CONFIG_ROOT}/src/utils/array.zsh

usage() {
  modes=('install' 'configure' 'uninstall')
  profiles=($(ls -1 "${CLI_CONFIG_ROOT}/profiles"))
  tools=($(ls -1 $CLI_CONFIG_ROOT/src/installers | sed 's/\..*$//g' | sort | uniq))

  modes_str=$(array_str ", " "${modes[@]}")
  profiles_str=$(array_str "/" "${profiles[@]}")
  tools_str=$(array_str "," "${tools[@]}")

  echo "cli-config <mode> [-p|--profile=profileName] [-t|--tools=tool1,tool2]"
  printf "\n"
  echo "mode: ${modes_str} "
  echo "profile: ${profiles_str} "
  printf "tools: ${tools_str}\n"
}
