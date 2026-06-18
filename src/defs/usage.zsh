#!/usr/bin/env bash

. ${CLI_CONFIG_ROOT}/src/utils/array.zsh
. ${CLI_CONFIG_ROOT}/src/utils/tool-guards.zsh

usage() {
  modes=('install' 'configure')
  profiles=($(ls -1 "${CLI_CONFIG_ROOT}/profiles"))
  all_tools=$(ls -1 $CLI_CONFIG_ROOT/src/installers | sed 's/\..*$//g' | sort | uniq)
  active_tools=()
  deprecated_tools_found=()

  for tool in ${(f)all_tools}; do
    local is_deprecated=false
    for d in "${DEPRECATED_TOOLS[@]}"; do
      [[ "$tool" == "$d" ]] && is_deprecated=true && break
    done
    if $is_deprecated; then
      deprecated_tools_found+=("$tool")
    else
      active_tools+=("$tool")
    fi
  done

  printf "CLI-CONFIG\n"

  modes_str=$(array_str ", " "${modes[@]}")
  profiles_str=$(array_str "/" "${profiles[@]}")
  active_tools_str=$(array_str "," "${active_tools[@]}")
  deprecated_tools_str=$(array_str "," "${deprecated_tools_found[@]}")
  plugin_managers_str=$(array_str "/" "${PLUGIN_MANAGERS[@]}")

  echo "./setup.sh <mode> [-p|--profile=profileName] [-t|--tools=tool1,tool2]"
  printf "\n\n"
  echo "mode: ${modes_str} "
  echo "profile: ${profiles_str} "
  printf "tools: ${active_tools_str}\n"
  printf "  plugin manager (choose one, default: ${PLUGIN_MANAGER_DEFAULT}): ${plugin_managers_str}\n"
  printf "  deprecated (use ${DEPRECATED_TOOLS_REPLACEMENT} instead): ${deprecated_tools_str}\n"
}
