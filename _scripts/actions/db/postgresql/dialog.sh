#!/bin/bash

# PostgreSQL screen dialog
# ---------------------------------------------------------------------

# Select an action
IFS=$'\n' SELECTED="$( \
  . ./scripts/dialog/select.sh 'PostgreSQL' \
      'list' 'List PostgreSQL docker images' \
      'pull' 'Pull PostgreSQL docker image' \
)"

# Forward to selected action
if [[ $SELECTED == "list" ]]; then
  . ./scripts/actions/db/postgresql/action_list.sh
elif [[ $SELECTED == "pull" ]]; then
  . ./scripts/actions/db/postgresql/action_pull.sh

# No action selected, back
else
  . ./scripts/actions/db/dialog.sh
fi
