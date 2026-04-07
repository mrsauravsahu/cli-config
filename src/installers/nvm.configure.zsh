TOOL=nvm
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh

echo -n >$CONF
printf 'export NVM_DIR="$CLI_CONFIG_ROOT/current/nvm"\n' >>$CONF
printf "# add nvm to path\n" >>$CONF
printf 'export PATH="$NVM_DIR:$PATH"\n' >>$CONF
# printf 'lazyload nvm node npm -- "source $NVM_DIR/nvm.sh"' >>$CONF
# turn off lazyload until I figure out how to let it work with AI agents

