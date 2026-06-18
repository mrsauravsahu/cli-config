read_options() {
  . $CLI_CONFIG_ROOT/src/utils/tool-guards.zsh

  # DEFAULT OPTIONS
  CCOPT_PROFILE=default
  CCOPT_NO_SUDO='sudo'
  CCOPT_DEBIAN_FRONTEND=''
  CCOPT_TOOLS=('zimfw' 'ohmyposh' 'asdf' 'dotnet')

  # READ OPTIONS
  # Todo: Move to separate file
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      . $CLI_CONFIG_ROOT/src/defs/usage.zsh
      usage
      exit
      ;;
    -c | --clean)
      CCOPT_CLEAN=true
      shift
      ;;
    -p | --profile)
      profiles=($(ls -1 $CLI_CONFIG_ROOT/profiles))
      CCOPT_PROFILE=$2
      if [ "$(array_contains "$CCOPT_PROFILE" "${profiles[@]}")" = "false" ]; then
        echo "The specified profile '$CCOPT_PROFILE' does not exist. "
        echo "Available profiles: $(array_str ' | ' ${profiles[@]})"
        exit
      fi
      shift
      shift
      ;;
    -n | --no-sudo)
      CCOPT_NO_SUDO=''
      shift
      ;;
    -t | --tools)
      allowedPrograms=($(ls -1 $CLI_CONFIG_ROOT/src/installers | sed 's/\..*$//g' | sort | uniq))

      if [ "$2" = "" ]; then
        Log "\"-t|--tools\" No tool selected, skipping installation."
        exit
      fi

      CCOPT_TOOLS=($(echo $2 | sed 's/,/\n/g'))
      CCOPT_TOOLS_EXPLICIT=true
      invalidPrograms=()
      for program in "${CCOPT_TOOLS[@]}"; do
        (! test -f $CLI_CONFIG_ROOT/src/installers/${program}.install.zsh) && invalidPrograms+=($program)
      done

      if [ "${#invalidPrograms[@]}" -ne 0 ]; then
        Log "\"-t|--tools\" Found invalid tools, skipping installation - '$(array_str ',' ${invalidPrograms[@]})'"
        exit
      fi

      validate_tools "${CCOPT_TOOLS[@]}"
      shift
      shift
      ;;
    --ci)
      CCOPT_DEBIAN_FRONTEND='DEBIAN_FRONTEND=noninteractive'
      shift
      ;;
    *)
      # Unrecognized option
      shift
      ;;
    esac
  done
}
