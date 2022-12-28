#!/bin/bash
#
# Display command selection dialog
# ---------------------------------------------------------------------

# Don't exit on errors (needed for dialog tree to work properly)
set +e

# Get path from args
NAVIGATION_PATH=$1
# Read configuration
NAV_TITLE=$(        echoConfiguration | jq -r "$NAVIGATION_PATH.title")
NAV_DESCRIPTION=$(  echoConfiguration | jq -r "$NAVIGATION_PATH.description")
NAV_CHILDREN=$(     echoConfiguration | jq -r "$NAVIGATION_PATH.children")
if [ "$NAV_CHILDREN" != "null" ]; then
  NAV_CHILDREN=$(   echoConfiguration | jq -r "$NAVIGATION_PATH.children | keys | join(\" \")")
else
  NAV_CHILDREN=()
fi
NAV_EXEC=$(         echoConfiguration | jq -r "$NAVIGATION_PATH.exec")
if [ "$NAV_EXEC" != "null" ]; then
  NAV_EXEC=$(       echoConfiguration | jq -r "$NAVIGATION_PATH.exec.command")
  NAV_EXEC_ARGS=$(  echoConfiguration | jq -r "$NAVIGATION_PATH.exec.args")
fi

# Check if navigated path is executable
if [ "$NAV_EXEC" != "null" ]; then

  # Run dialog
  . $ROOT/commands/$NAV_EXEC/dialog.sh $NAV_TITLE $NAV_DESCRIPTION $NAVIGATION_PATH_FRIENDLY $NAV_EXEC_ARGS ${ARGS_UNPROCESSED[*]}
  exit 0

fi

# Check if children to select
if [ ! ${#NAV_CHILDREN} -eq 0 ]; then
  
  # Compose options based on path
  IFS=" " read -r -a KEYS <<< "$NAV_CHILDREN"
  SELECT_OPTIONS=()
  SELECT_OPTION_KEYS=()
  for KEY in "${KEYS[@]}"; do
    TITLE=$(      echoConfiguration | jq -r "$NAVIGATION_PATH.children.$KEY.title")
    DESCRIPTION=$(echoConfiguration | jq -r "$NAVIGATION_PATH.children.$KEY.description")
    SELECT_OPTIONS+=($KEY "$DESCRIPTION")
    SELECT_OPTION_KEYS+=($KEY)
  done


  # Compose actions based on path
  if [ ! ${#NAV_CHILDREN} -eq 0 ]; then
    LABEL_OK="Select"
  else
    LABEL_OK="Select"
  fi

  if [ "$NAVIGATION_PATH" == "" ]; then
    LABEL_CANCEL="Exit"
  else
    LABEL_CANCEL="Back"
  fi

  # Select a command
  SELECTED=$(
    dialog  --clear --stdout --keep-tite                \
            --output-fd 1                               \
            --backtitle "'$NAVIGATION_PATH'"                    \
            --ok-label "$LABEL_OK"                      \
            --cancel-label "$LABEL_CANCEL"              \
            --no-tags --menu "$NAV_DESCRIPTION" 10 80 0 \
            "${SELECT_OPTIONS[@]}"                      \
  )

  # If selected action, update navigated path
  if [[ $? -eq 0 ]]; then
    # Run dialog with update path
    . $ROOT/commands/dialog.sh "$NAVIGATION_PATH.children.$SELECTED"

  # If no selected action and not root path
  elif [ "$NAVIGATION_PATH" != "" ]; then
    # Update path
    IFS='.' read -r -a NAVIGATION_PATH_ARRAY <<< "$NAVIGATION_PATH"
    NAVIGATION_PATH_LENGTH=${#NAVIGATION_PATH_ARRAY[@]}
    if [ $NAVIGATION_PATH_LENGTH -gt 3 ]; then
      # Update path
      NAVIGATION_PATH="${NAVIGATION_PATH_ARRAY[@]:0:$((${#NAVIGATION_PATH_ARRAY[@]} - 2))}"
      NAVIGATION_PATH="${NAVIGATION_PATH// /.}"
      # Run dialog with update path
      . $ROOT/commands/dialog.sh "$NAVIGATION_PATH"
    else
      # Run dialog with no path
      . $ROOT/commands/dialog.sh ""
    fi

  # If no selected action and root path
  else
    exit 0
  fi
fi

# Exit cleanly
exit 0
