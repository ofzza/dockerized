#!/bin/bash
#
# Docker instance management command: CONNECT
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
DOCKER_IMAGE=$DOCKER_IMAGE

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:1})

# Preprocess known, static arguments
DOCKER_INSTANCE_NAME=$(echo "ofzza::dockerized::$DOCKER_IMAGE" | sed -e 's/[^A-Za-z0-9_\-]/\-/g' )

# Check if instance already installed
echo
echo "- Checking if '$DOCKER_IMAGE' ('$DOCKER_INSTANCE_NAME') container exists ..."
# If docker image not installed, exit with error
DOCKER_CONTAINER_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ -z "$DOCKER_CONTAINER_ID" ]; then
  echo "  ERROR: Docker container not found!"
  exit 1
else
  echo "  ... Docker container found;  proceeding ..."
fi

# Start container
echo
echo "- Connecting to '$DOCKER_IMAGE' ('$DOCKER_INSTANCE_NAME') container ..."
docker container run $DOCKER_INSTANCE_NAME -c bash #> /dev/null 2>&1
echo "  ... done!"

# Exit cleanly
exit 0
