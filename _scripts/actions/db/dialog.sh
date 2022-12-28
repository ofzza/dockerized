#!/bin/bash

# Databases screen dialog
# ---------------------------------------------------------------------

# Select an action
IFS=$'\n' SELECTED=$(. "./scripts/dialog/select_action.sh" "Select a database" "./scripts/actions/db")

# Check selected action
[[ ! -z $SELECTED ]] && . "./scripts/actions/db/$SELECTED/dialog.sh" || . "./scripts/dialog.sh"
