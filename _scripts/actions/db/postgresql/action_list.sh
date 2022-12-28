#!/bin/bash

# PostgreSQL "list" action
# ---------------------------------------------------------------------

# List existing postgresql docker container
CONTAINERS=$(docker image ls | grep "postgres" | tr -s ' ')
IFS=$'\n' OPTIONS=()
INDEX=0
for CONTAINER in $CONTAINERS; do
  OPTIONS+=($INDEX) && INDEX=$((INDEX + 1))
  OPTIONS+=($CONTAINER)
done

# If no containers found, forward to "create" action
if [[ -z "$CONTAINERS" ]]; then
  # Show no images prompt
  . ./scripts/dialog/msgbox.sh 'No PostgreSQL docker containers found on the system!'
  # Return to previous dialog
  . ./scripts/actions/db/postgresql/dialog.sh

# Display the available containers and "actions"
else
  # Select a container
  SELECTED=$(. ./scripts/dialog/select.sh 'PostgreSQL docker containers' ${OPTIONS[@]})

  # If container selected, run a selected container
  if [[ ! -z $SELECTED ]]; then
    echo "Brum brum: $SELECTED"
    exit

  # If no container selected, return to previous dialog
  else 
    . ./scripts/actions/db/postgresql/dialog.sh
  fi
fi
