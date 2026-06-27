TOOL=ohmyposh
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh

echo -n >$CONF
printf 'eval "$($CLI_CONFIG_ROOT/current/ohmyposh/oh-my-posh init zsh --config $CLI_CONFIG_ROOT/current/ohmyposh/themes/$CLI_CONFIG_THEME.omp.json)"\n' >>$CONF
printf 'if [[ -n "$NVIM" ]]; then\n' >>$CONF
printf '  _omp_strip_zwsp() {\n' >>$CONF
printf '%s\n' "    local zwsp=\$'\\xe2\\x80\\x8b'" >>$CONF
printf '    PROMPT="${PROMPT//$zwsp/}"\n' >>$CONF
printf '    RPROMPT="${RPROMPT//$zwsp/}"\n' >>$CONF
printf '  }\n' >>$CONF
printf '  add-zsh-hook precmd _omp_strip_zwsp\n' >>$CONF
printf 'fi\n' >>$CONF
