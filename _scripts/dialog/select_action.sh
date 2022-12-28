#!/bin/bash

# Dialog menu selecting a action (represented as a directory with .info file within)
# ---------------------------------------------------------------------

# Collect actions
IFS=$'\n' ACTIONS=()
for NAME in $(ls $2/*/ -dA1 | xargs basename); do
  DESCRIPTION="$(cat $2/$NAME/.info)"
  ACTIONS+=($NAME)
  ACTIONS+=($DESCRIPTION)
done

# Open select dialog with basic action selection
SELECTED="$(. ./scripts/dialog/select.sh $1 ${ACTIONS[@]})"


# Return selected
if [[ ! -z $SELECTED ]]; then
  echo $SELECTED;
  exit 0

# Return not selected
else
  exit 1
fi
