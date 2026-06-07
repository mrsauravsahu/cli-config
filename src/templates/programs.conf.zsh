autoload -Uz compinit && compinit

# init all cli-config tools
for tool in $(find $CLI_CONFIG_CONF_LOCATION -type f -name '*.sh' | sort); do . $tool; done

# alias cls to clear
alias cls=clear
