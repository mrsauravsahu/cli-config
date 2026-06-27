#!/usr/bin/env zsh

PLUGIN_MANAGERS=('zimfw' 'antigen')
PLUGIN_MANAGER_DEFAULT='zimfw'
DEPRECATED_TOOLS=('tfenv' 'pyenv' 'nvm' 'gvm')
DEPRECATED_TOOLS_REPLACEMENT='asdf'

validate_tools() {
  local tools=("$@")
  local plugin_manager_count=0
  local errors=()

  for tool in "${tools[@]}"; do
    # deprecation check
    for deprecated in "${DEPRECATED_TOOLS[@]}"; do
      if [[ "$tool" == "$deprecated" ]]; then
        echo "[cli-config] Warning: '$tool' is deprecated — use '$DEPRECATED_TOOLS_REPLACEMENT' instead."
      fi
    done

    # count how many plugin managers were requested
    for pm in "${PLUGIN_MANAGERS[@]}"; do
      if [[ "$tool" == "$pm" ]]; then
        ((plugin_manager_count++))
      fi
    done
  done

  if ((plugin_manager_count > 1)); then
    pm_list=$(printf '%s, ' "${PLUGIN_MANAGERS[@]}")
    pm_list=${pm_list%, }
    echo "[cli-config] Error: only one plugin manager can be specified ($pm_list). Got $plugin_manager_count."
    exit 1
  fi
}
