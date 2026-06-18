TOOL=asdf
CONF=$CLI_CONFIG_CONF_LOCATION/$TOOL.conf.sh
INSTALL_DIR=$CLI_CONFIG_ROOT/current/asdf

echo -n >$CONF
tee $CONF >/dev/null <<'EOF'
export ASDF_DIR="$CLI_CONFIG_ROOT/current/asdf"
export ASDF_DATA_DIR="$CLI_CONFIG_ROOT/current/asdf"
. "$ASDF_DIR/asdf.sh"
EOF
