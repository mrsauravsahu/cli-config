TOOL=asdf
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh
INSTALL_DIR=$CLI_CONFIG_ROOT/current/asdf

echo -n >$CONF
tee $CONF >/dev/null <<'EOF'
export ASDF_DIR="$CLI_CONFIG_ROOT/current/asdf"
# ASDF_DATA_DIR holds plugins and runtimes — keep at ~/.asdf so they survive reinstalls
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
. "$ASDF_DIR/asdf.sh"
EOF
