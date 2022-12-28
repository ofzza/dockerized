#!/bin/bash
#
# Docker instance management command: Stop
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

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:1})

echo "STOP"                             #!DEBUG
printf "%s", " ${ARGS_PROCESSED[@]}"    #!DEBUG
echo                                    #!DEBUG
printf "%s", " ${ARGS_UNPROCESSED[@]}"  #!DEBUG
echo                                    #!DEBUG
exit 1                                  #!DEBUG
