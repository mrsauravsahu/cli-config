. ${CLI_CONFIG_ROOT}/src/utils/array.zsh
. ${CLI_CONFIG_ROOT}/src/utils/log.zsh
. ${CLI_CONFIG_ROOT}/src/utils/prompt.zsh

_uninstall_confirm() {
  local message="$1"
  shift
  local opts=("$@")
  while true; do
    response=($(echo $(Prompt "$message" true "${opts[@]}")))
    local isValid="${response[2]}"
    local entered=$(echo "${response[1]}" | tr 'A-Z' 'a-z')
    [[ "$isValid" == "true" ]] && echo "$entered" && return
  done
}

_uninstall_full() {
  . ${CLI_CONFIG_ROOT}/src/scripts/env.zsh

  local targets=()
  local symlinks=()

  [[ -d "$CLI_CONFIG_ROOT/current" ]] && targets+=("$CLI_CONFIG_ROOT/current  (all installed tools and generated conf)")

  for f in ~/.zshrc ~/.gitconfig; do
    if [[ -L "$f" ]]; then
      local dest=$(readlink "$f")
      [[ "$dest" == ${CLI_CONFIG_ROOT}* ]] && symlinks+=("$f -> $dest")
    fi
  done

  if [[ ${#targets[@]} -eq 0 && ${#symlinks[@]} -eq 0 ]]; then
    Log "Nothing to uninstall — no cli-config installation found."
    return
  fi

  echo
  echo "The following will be deleted:"
  for t in "${targets[@]}"; do echo "  - $t"; done
  for s in "${symlinks[@]}"; do echo "  - symlink: $s"; done
  echo

  local first=$(_uninstall_confirm "Are you sure you want to fully uninstall cli-config?" "y" "N")
  if [[ "$first" != "y" ]]; then
    Log "Uninstall cancelled."
    return
  fi

  local second=$(_uninstall_confirm "This is irreversible. Confirm deletion?" "y" "N")
  if [[ "$second" != "y" ]]; then
    Log "Uninstall cancelled."
    return
  fi

  if [[ -d "$CLI_CONFIG_ROOT/current" ]]; then
    Log "Removing $CLI_CONFIG_ROOT/current..."
    rm -rf "$CLI_CONFIG_ROOT/current"
  fi

  for f in ~/.zshrc ~/.gitconfig; do
    if [[ -L "$f" ]]; then
      local dest=$(readlink "$f")
      if [[ "$dest" == ${CLI_CONFIG_ROOT}* ]]; then
        Log "Removing symlink $f..."
        rm "$f"
      fi
    fi
  done

  echo
  Log "cli-config uninstalled. Start a new shell or set up a fresh ~/.zshrc."
}

_uninstall_tools() {
  responseYesToAll=false
  confirmationOptions=('y' 'N' 'a')

  for tool in "${CCOPT_TOOLS[@]}"; do
    if [ "${responseYesToAll}" = "false" ]; then
      while true; do
        response=($(echo $(Prompt "Are you sure you want to uninstall '${tool}'?" true "${confirmationOptions[@]}")))
        receivedValidResponse="${response[2]}"
        enteredOption=$(echo "${response[1]}" | tr 'A-Z' 'a-z')

        if [ "${enteredOption}" = "a" ]; then
          responseYesToAll=true
          break
        elif [ "${enteredOption}" = "" ] || [ "${receivedValidResponse}" = "true" ]; then
          break
        fi
      done
    else
      enteredOption="a"
    fi

    if [ "${enteredOption}" = "" ] || [ "${enteredOption}" = "n" ]; then
      Log "Skipping uninstall of ${tool}."
      continue
    fi

    if [ "${enteredOption}" = "y" ] || [ "${enteredOption}" = "a" ]; then
      Log "Running uninstall script for '${tool}'..."
      uninstallScriptPath="${CLI_CONFIG_ROOT}/src/installers/${tool}.uninstall.zsh"
      if [ -f "${uninstallScriptPath}" ]; then
        . ${uninstallScriptPath}
      else
        rm -rf ${CLI_CONFIG_ROOT}/current/${tool} 2>/dev/null
        rm -rf ${CLI_CONFIG_ROOT}/current/conf/${tool}.conf.sh
      fi
      Log "Done."
    fi
  done
}

uninstall() {
  if [[ -n "$CCOPT_TOOLS_EXPLICIT" ]]; then
    _uninstall_tools
  else
    _uninstall_full
  fi
}
