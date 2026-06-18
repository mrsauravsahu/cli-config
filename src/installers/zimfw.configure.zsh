TOOL=zimfw
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.zsh
ZIMRC=$CLI_CONFIG_CONF_LOCATION/.zimrc
ZIMFW_HOME=$CLI_CONFIG_ROOT/current/zimfw

# Write .zimrc (module list used by zimfw install/update)
tee $ZIMRC >/dev/null <<'EOF'
zmodule qoomon/zsh-lazyload
zmodule zsh-users/zsh-autosuggestions
zmodule ptavares/zsh-direnv
zmodule ohmyzsh/ohmyzsh --root plugins/autojump
zmodule zsh-users/zsh-syntax-highlighting
zmodule ohmyzsh/ohmyzsh --root plugins/git
EOF

# Run zimfw install now (at configure time) to generate init.zsh — no network I/O at shell startup
Log "Running zimfw install to fetch plugins..."
ZIM_HOME=$ZIMFW_HOME ZIM_CONFIG_FILE=$ZIMRC zsh $CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh install

# Write conf — shell startup just sources the pre-built init.zsh
echo -n >$CONF
tee $CONF >/dev/null <<EOF
[[ "\${CLI_CONFIG_MODULES:-zimfw}" != "zimfw" ]] && return

export ZIMFW_HOME=\${CLI_CONFIG_ROOT}/current/zimfw
export ZIM_HOME=\$ZIMFW_HOME

source "\${ZIMFW_HOME}/init.zsh"
EOF
