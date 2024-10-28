#!/bin/bash
#
# Command parsing
# ---------------------------------------------------------------------

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:1})

# Initialize state
NAVIGATION_PATH=""
NAVIGATION_PATH_FRIENDLY=""
NAVIGATION_PATH_FRIENDLY_BASH=""
NAVIGATION_PATH_FRIENDLY_FULL=""
NAVIGATION_PATH_HELP_ARRAY=()
NAVIGATION_PATH_FULL=""
NAVIGATION_PATH_ERROR=0
COMMAND_HELP=0
COMMAND_DUMP_CONFIG=0
COMMAND_INTERACTIVE=0

# Define utilities
CONFIGURATION_CACHE="null"
function echoConfiguration {
  # If already not cached, read configuration
  if [ $CONFIGURATION_CACHE == "null" ]; then
    # Collect all configs
    CONFIGURATION_JSON="{}"
    for CONFIG_FILEPATH in ./conf/*; do
      CONFIGURATION_JSON="$CONFIGURATION_JSON $(cat $CONFIG_FILEPATH | grep -v "^\s*//")"
    done
    # Read and merge all configs
    CONFIGURATION_CACHE=$(echo $CONFIGURATION_JSON | jq --slurp 'reduce .[] as $item ({}; . * $item)')
  fi
  
  # Return cached configuration
  echo $CONFIGURATION_CACHE
}

function echoConfigurationPath {
  CONFIGURATION=$(echoConfiguration | jq -r "$1")
  echo $CONFIGURATION
}

# Parse arguments and navigation path and execute command
while [[ $# -gt 0 ]]; do
  # Evaluate arg
  ARG_EVALUATED=0
  case $1 in
    
    # Display help
    -\?|--help)
      ARG_EVALUATED=1
      COMMAND_HELP=1
      ;;

    # Display full configuration JSON
    --dump-config)
      ARG_EVALUATED=1
      COMMAND_DUMP_CONFIG=1
      ;;

    # Display interactive dialog
    -i|--interactive)
      ARG_EVALUATED=1
      COMMAND_INTERACTIVE=1
      ;;

    # Ignore all other args starting with "-" or "--"
    -*|--*)
      ;;

    # Consider part of path
    *)
      # Verify path is valid
      NAVIGATION_PATH_FULL="$NAVIGATION_PATH_FULL.$1"
      NAVIGATION_PATH_NEXT="$NAVIGATION_PATH.children.$1"
      if [ ! $NAVIGATION_PATH_ERROR -eq 1 ]; then
        RESULT=$(echoConfigurationPath $NAVIGATION_PATH_NEXT)      
        if [ $RESULT != "null" ]; then
          # Consider evaluated as part of path
          ARG_EVALUATED=1
          # Append path
          NAVIGATION_PATH=$NAVIGATION_PATH_NEXT
          NAVIGATION_PATH_FRIENDLY="$NAVIGATION_PATH_FRIENDLY.$1"
          NAVIGATION_PATH_FRIENDLY_BASH="$NAVIGATION_PATH_FRIENDLY_BASH $1"
          TITLE=$(      echoConfiguration | jq -r "$NAVIGATION_PATH.title")
          DESCRIPTION=$(echoConfiguration | jq -r "$NAVIGATION_PATH.description")
          NAVIGATION_PATH_HELP_ARRAY+=("$1 $DESCRIPTION")
          NAVIGATION_PATH_FRIENDLY_FULL="$NAVIGATION_PATH_FRIENDLY_FULL > $TITLE"
        else
          # Stop appending to path and show help
          NAVIGATION_PATH_ERROR=1
          COMMAND_HELP=1
        fi
      fi
      ;;

  esac

  # Move onto next arg
  if [ $ARG_EVALUATED -eq 1 ]; then
    ARGS_PROCESSED+=("$1");
    ARGS_UNPROCESSED=("${ARGS_UNPROCESSED[@]:1}")
  fi
  shift

done

# If path error, echo path error
# if [ $NAVIGATION_PATH_ERROR -eq 1 ]; then
#   echo "ERROR: Requested path '$NAVIGATION_PATH_FULL' not supported!";
#   echo "----------------------------------------------------------"
#   echo
# fi

# Read configuration
NAV_TITLE=$(        echoConfiguration | jq -r "$NAVIGATION_PATH.title")
NAV_DESCRIPTION=$(  echoConfiguration | jq -r "$NAVIGATION_PATH.description")
NAV_CHILDREN=$(     echoConfiguration | jq -r "$NAVIGATION_PATH.children")
if [ "$NAV_CHILDREN" != "null" ]; then
  NAV_CHILDREN=$(   echoConfiguration | jq -r "$NAVIGATION_PATH.children | keys | join(\" \")")
else
  NAV_CHILDREN=()
fi
NAV_EXEC=$(         echoConfiguration | jq -r "$NAVIGATION_PATH.exec")
if [ "$NAV_EXEC" != "null" ]; then
  NAV_EXEC=$(       echoConfiguration | jq -r "$NAVIGATION_PATH.exec.command")
  NAV_EXEC_ARGS=$(  echoConfiguration | jq -r "$NAVIGATION_PATH.exec.args")
fi

# Check if navigated path is executable
if [ "$NAV_EXEC" != "null" ]; then

  # If non-interactive, execute valid path command
  if [ ! $COMMAND_INTERACTIVE -eq 1 ]; then
    # Run command
    . $ROOT/commands/$NAV_EXEC/run.sh ${ARGS_UNPROCESSED[*]}
    exit 0
  else
    # Run dialog
    . $ROOT/commands/$NAV_EXEC/dialog.sh $NAV_TITLE $NAV_DESCRIPTION $NAVIGATION_PATH_FRIENDLY $NAV_EXEC_ARGS ${ARGS_UNPROCESSED[*]}
    exit 0
  fi


# If not executable, and no other --something command, help needed ...
elif [ $COMMAND_DUMP_CONFIG -eq 0 ]; then
  COMMAND_HELP=1
fi

# If interactive, display interactive dialog
if [ $COMMAND_INTERACTIVE -eq 1 ]; then
  . $ROOT/commands/dialog.sh $NAVIGATION_PATH
  exit 0
fi

# If help, output help
if [ $COMMAND_HELP -eq 1 ]; then
  # Help header
  echo "Docker utility script ($NAV_DESCRIPTION)"
  echo
  echo "Usage:"
  echo "  . run.sh [Arguments] [Path]"
  echo
  echo "Path:"
  
  # Echo valid path
  if [ ! ${#NAVIGATION_PATH_HELP_ARRAY} -eq 0 ]; then
    for HELP in "${NAVIGATION_PATH_HELP_ARRAY[@]}"; do
      IFS=' ' read -r -a HELP <<< "$HELP"
      echo "  $(printf "%-23s" ${HELP[0]}) ${HELP[@]:1}"
    done
  fi

  # Echo options for future path
  if [ ! ${#NAV_CHILDREN} -eq 0 ]; then
    echo "  ..."
    IFS=" " read -r -a KEYS <<< "$NAV_CHILDREN"
    for KEY in "${KEYS[@]}"; do
      TITLE=$(      echoConfiguration | jq -r "$NAVIGATION_PATH.children.$KEY.title")
      DESCRIPTION=$(echoConfiguration | jq -r "$NAVIGATION_PATH.children.$KEY.description")
      echo "  $(printf "%-23s" [$KEY]) $DESCRIPTION"
    done
  fi

  # Echo arguments
  echo
  echo "Arguments:"
  echo "  -? | --help:            Displays this help dialog"
  echo "  -i | --interactive:     Opens up a interactive dialog"
  echo "  --dump-config:          Displays full configuration JSON"

  # Exit after help output
  exit 0
fi

# If configuration dump, dump configuration
if [ $COMMAND_DUMP_CONFIG -eq 1 ]; then
  # Dump full configuration
  echoConfiguration

  # Exit after config dump output
  exit 0
fi

# Command not properly interpreted
exit 1
