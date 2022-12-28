#!/bin/bash

# Home screen dialog
# ---------------------------------------------------------------------

# Select an action
IFS=$'\n' SELECTED=$(. "./scripts/dialog/select_action.sh" "Dockerize" "./scripts/actions")

# Check selected action
[[ ! -z $SELECTED ]] && . "./scripts/actions/$SELECTED/dialog.sh" || exit 0
