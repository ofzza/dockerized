#!/bin/bash
#
# Manage server dialog
# ---------------------------------------------------------------------

# Parse input args
NAV_TITLE=$1
NAV_DESCRIPTION=$2
NAVIGATION_PATH=$3
COMMAND_ARGUMENTS_JSON=$4

# Display args
dialog  --clear --keep-tite \
        --output-fd 1 \
        --msgbox "$NAV_TITLE $NAV_DESCRIPTION $NAVIGATION_PATH $COMMAND_ARGUMENTS_JSON" 10 40

# Exit cleanly
exit 0
