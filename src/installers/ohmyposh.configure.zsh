TOOL=ohmyposh
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh

echo -n >$CONF
# `oh-my-posh init zsh` costs ~170ms per shell start. Its output only changes when
# the binary or the theme changes, so cache it and re-generate when either is newer.
printf '_omp_bin=$CLI_CONFIG_ROOT/current/ohmyposh/oh-my-posh\n' >>$CONF
printf '_omp_theme=$CLI_CONFIG_ROOT/current/ohmyposh/themes/$CLI_CONFIG_THEME.omp.json\n' >>$CONF
printf '_omp_cache=$CLI_CONFIG_ROOT/current/ohmyposh/init.$CLI_CONFIG_THEME.zsh\n' >>$CONF
printf 'if [[ ! -s $_omp_cache || $_omp_bin -nt $_omp_cache || $_omp_theme -nt $_omp_cache ]]; then\n' >>$CONF
# POSH_SESSION_ID is a fresh UUID per `init` call and keys oh-my-posh's segment
# cache, so it must stay per-shell rather than being frozen into the cached file.
printf '  $_omp_bin init zsh --config $_omp_theme | grep -v "^export POSH_SESSION_ID=" >| $_omp_cache\n' >>$CONF
printf 'fi\n' >>$CONF
printf 'source $_omp_cache\n' >>$CONF
printf 'export POSH_SESSION_ID="cli-config-$$-${RANDOM}${RANDOM}"\n' >>$CONF
printf 'unset _omp_bin _omp_theme _omp_cache\n' >>$CONF
printf 'if [[ -n "$NVIM" ]]; then\n' >>$CONF
printf '  _omp_strip_zwsp() {\n' >>$CONF
printf '%s\n' "    local zwsp=\$'\\xe2\\x80\\x8b'" >>$CONF
printf '    PROMPT="${PROMPT//$zwsp/}"\n' >>$CONF
printf '    RPROMPT="${RPROMPT//$zwsp/}"\n' >>$CONF
printf '  }\n' >>$CONF
printf '  add-zsh-hook precmd _omp_strip_zwsp\n' >>$CONF
printf 'fi\n' >>$CONF
