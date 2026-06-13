if [ -f "$CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh" ]; then
  Log 'Seems zimfw is already installed!'
else
  Log "Installing zimfw plugin manager"
  curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh \
    -o $CLI_CONFIG_TOOLS_LOCATION/zimfw.zsh
  mkdir -p $CLI_CONFIG_ROOT/current/zimfw 2>/dev/null
fi
