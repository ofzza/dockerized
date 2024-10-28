#!/bin/bash
#
# Docker instance management command: STATUS
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

# Prompt status
echo "Status: "

# Check if image already installed
DOCKER_IMAGE_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ -z "$DOCKER_IMAGE_ID" ]; then
  echo "  - Image ($DOCKER_IMAGE) NOT INSTALLED!"
else
  echo "  - Image ($DOCKER_IMAGE) INSTALLED!"
fi

# Check if instance already installed
DOCKER_CONTAINER_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
DOCKER_CONTAINER_STARTED_ID=$(docker container ls --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ -z "$DOCKER_CONTAINER_ID" ]; then
  echo "  - Container ($DOCKER_IMAGE) NOT INSTALLED!"
  exit 1
elif [ -z "$DOCKER_CONTAINER_STARTED_ID" ]; then
  echo "  - Container ($DOCKER_IMAGE) INSTALLED but STOPPED!"
else
  echo "  - Container ($DOCKER_IMAGE) INSTALLED and STARTED!"
fi

# Exit cleanly
exit 0
