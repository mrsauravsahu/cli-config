TOOL=asdf
INSTALL_DIR=$CLI_CONFIG_ROOT/current/asdf

APP_VERSION='v0.16.7'

if [ -d $INSTALL_DIR ]; then
  Log 'Seems cli-config/asdf is already installed!'
else
  Log "Installing asdf ${APP_VERSION}"
  git clone https://github.com/asdf-vm/asdf.git $INSTALL_DIR --branch ${APP_VERSION} --depth=1
fi
