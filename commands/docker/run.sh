#!/bin/bash
#
# Docker instance management command
# ---------------------------------------------------------------------

# Get script root directory
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Exit on any error
set -e
function cleanup {
  set +e
}
trap cleanup EXIT

# Variables
IFS=""

# Inherit arguments
NAV_TITLE=$NAV_TITLE
NAV_DESCRIPTION=$NAV_DESCRIPTION
NAVIGATION_PATH_FRIENDLY=$NAVIGATION_PATH_FRIENDLY
NAV_EXEC_ARGS=$NAV_EXEC_ARGS

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:5})

# Preprocess known, static arguments
DOCKER_IMAGE=$(echo $NAV_EXEC_ARGS | jq -r ".dockerimg")
DOCKER_ENV=$(echo $NAV_EXEC_ARGS | jq -r '.dockerenv | to_entries | map(("--env " + .key + "=" + .value)) | join(" ")')

# Initialize state
COMMAND_HELP=0
COMMAND_DOCKER="null"

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

    # Status of docker image/instance
    --status)
      ARG_EVALUATED=1
      COMMAND_DOCKER="status"
      ;;

    # Install docker image
    --install)
      ARG_EVALUATED=1
      COMMAND_DOCKER="install"
      ;;

    # Remove docker image
    --uninstall)
      ARG_EVALUATED=1
      COMMAND_DOCKER="uninstall"
      ;;

    # Start docker instance
    --start)
      ARG_EVALUATED=1
      COMMAND_DOCKER="start"
      ;;

    # Stop docker instance
    --stop)
      ARG_EVALUATED=1
      COMMAND_DOCKER="stop"
      ;;

    # Connect into the docker instance
    --connect)
      ARG_EVALUATED=1
      COMMAND_DOCKER="connect"
      ;;

    # Ignore all other args starting with "-" or "--"
    -*|--*)
      COMMAND_HELP=1
      ;;

    # Consider part of path
    *)
      COMMAND_HELP=1
      ;;

  esac

  # Move onto next arg
  if [ $ARG_EVALUATED -eq 1 ]; then
    ARGS_PROCESSED+=("$1");
    ARGS_UNPROCESSED=("${ARGS_UNPROCESSED[@]:1}")
  fi
  shift
  
done

# Check if docker command present
if [ "$COMMAND_DOCKER" != "null" ]; then

  # Run command
  . $ROOT/commands/run-$COMMAND_DOCKER.sh ${ARGS_UNPROCESSED[*]}
  exit 0

# If no docker command, help needed ...
else
  COMMAND_HELP=1
fi

# Preprocess known, static arguments
DOCKER_INSTANCE_NAME=$(echo "ofzza::dockerized::$DOCKER_IMAGE" | sed -e 's/[^A-Za-z0-9_\-]/\-/g' )

# If help, output help
if [ $COMMAND_HELP -eq 1 ]; then
  # Help header
  echo "Docker utility script ($NAV_DESCRIPTION)"
  echo
  echo "Usage:"
  echo "  . run.sh $NAVIGATION_PATH_FRIENDLY [Command]" #TODO: Format!
  echo
  echo "Commands:"
  echo "  --status:               Outputs status of $NAV_TITLE image/container ($DOCKER_IMAGE / $DOCKER_INSTANCE_NAME)"
  echo "  --install:              Installs $NAV_TITLE image ($DOCKER_IMAGE)"
  echo "  --uninstall:            Uninstalls $NAV_TITLE image ($DOCKER_IMAGE)"
  echo "  --start:                Starts $NAV_TITLE container ($DOCKER_INSTANCE_NAME)"
  echo "  --stop:                 Stops $NAV_TITLE container ($DOCKER_INSTANCE_NAME)"
  echo "  --connect:              Connects to $NAV_TITLE container ($DOCKER_INSTANCE_NAME)"

  # Output docker image/container status
  echo;
  . $ROOT/commands/run-status.sh ${ARGS_UNPROCESSED[*]}

  # Exit after help output
  exit 0
fi

# Command not properly interpreted
exit 1
