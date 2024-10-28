#!/bin/bash
#
# Docker instance management command: Install
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
DOCKER_ENV=$DOCKER_ENV

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:1})

# Preprocess known, static arguments
DOCKER_INSTANCE_NAME=$(echo "ofzza::dockerized::$DOCKER_IMAGE" | sed -e 's/[^A-Za-z0-9_\-]/\-/g' )

# Check if instance already installed
echo
echo "- Checking if '$DOCKER_IMAGE' ('$DOCKER_INSTANCE_NAME') container already installed ..."
# If docker image already installed, exit with error
DOCKER_CONTAINER_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ ! -z "$DOCKER_CONTAINER_ID" ]; then
  echo "  ERROR: Docker container already installed!"
  exit 1
else
  echo "  ... Docker container not found; proceeding ..."
fi

# Install container
echo
echo "- Installing '$DOCKER_IMAGE' ('$DOCKER_INSTANCE_NAME') container ..."
# Pulling image
echo "  - Pulling image '$DOCKER_IMAGE' ..."
docker image pull $DOCKER_IMAGE > /dev/null 2>&1
echo "    ... done!"
# Installing image
echo "  - Installing image '$DOCKER_IMAGE' ..."
eval "docker container create $DOCKER_ENV --name $DOCKER_INSTANCE_NAME --publish 5432:5432 $DOCKER_IMAGE > /dev/null 2>&1"
echo "    ... done!"

# Exit cleanly
exit 0
