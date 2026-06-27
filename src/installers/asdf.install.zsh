TOOL=asdf
INSTALL_DIR=$CLI_CONFIG_ROOT/current/asdf
BIN_PATH=$INSTALL_DIR/bin/asdf

APP_VERSION='v0.19.0'

if [ -f $BIN_PATH ]; then
  Log 'Seems cli-config/asdf is already installed!'
else
  Log "Installing asdf ${APP_VERSION}"

  # Detect OS
  case "$(uname -s)" in
    Linux)  OS=linux ;;
    Darwin) OS=darwin ;;
    *) Log "Unsupported OS: $(uname -s)"; exit 1 ;;
  esac

  # Detect arch
  case "$(uname -m)" in
    x86_64)          ARCH=amd64 ;;
    aarch64|arm64)   ARCH=arm64 ;;
    i386|i686)       ARCH=386 ;;
    *) Log "Unsupported arch: $(uname -m)"; exit 1 ;;
  esac

  TARBALL="asdf-${APP_VERSION}-${OS}-${ARCH}.tar.gz"
  URL="https://github.com/asdf-vm/asdf/releases/download/${APP_VERSION}/${TARBALL}"

  TMP_DIR=$(mktemp -d)
  TMP_TARBALL="${TMP_DIR}/${TARBALL}"

  Log "Downloading ${URL}"
  curl -fsSL -o "$TMP_TARBALL" "$URL"

  mkdir -p "$INSTALL_DIR/bin"
  tar -xzf "$TMP_TARBALL" -C "$TMP_DIR"
  mv "$TMP_DIR/asdf" "$BIN_PATH"
  chmod +x "$BIN_PATH"

  rm -rf "$TMP_DIR"
  Log "asdf ${APP_VERSION} installed to ${BIN_PATH}"
fi
