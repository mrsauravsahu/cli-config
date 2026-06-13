TOOL=antigen
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh

echo -n >$CONF
tee $CONF >/dev/null <<EOF
[[ "\${CLI_CONFIG_MODULES:-antigen}" != "antigen" ]] && return

ADOTDIR=\${CLI_CONFIG_ROOT}/current/antigen
source \${CLI_CONFIG_TOOLS_LOCATION}/antigen.zsh

# use antigen to setup the terminal
antigen bundle qoomon/zsh-lazyload
antigen bundle zsh-users/zsh-autosuggestions
# Doesn't work on Mac without direnv and autojump installed with brew
# ptavares/zsh-direnv changed their default branch to main which broke antigen bundle - explicitly requesting main branch
antigen bundle ptavares/zsh-direnv@main
antigen bundle autojump
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle ohmyzsh/ohmyzsh plugins/git

# apply all antigen changes
antigen apply
EOF
