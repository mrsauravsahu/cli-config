#!/usr/bin/env zsh

PLUGIN_MANAGERS=('zimfw' 'antigen')
PLUGIN_MANAGER_DEFAULT='zimfw'

validate_tools() {
  local tools=("$@")
  local plugin_manager_count=0
  local errors=()

  for tool in "${tools[@]}"; do
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
