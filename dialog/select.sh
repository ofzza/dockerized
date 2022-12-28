#!/bin/bash
#
# Dialog: Menu
# ---------------------------------------------------------------------

# Open dialog with basic action selection
SELECTED="$(\
  dialog  --clear --keep-tite \
          --output-fd 1 \
          --backtitle "$DIALOG_TITLE" \
          --ok-label "$2" \
          --cancel-label "$3" \
          --no-tags --menu "$1" 10 80 0 ${@:4} \
)"

# Return selected
if [[ ! -z $SELECTED ]]; then
  echo $SELECTED;
  exit 0

# Return not selected
else
  exit 1
fi
