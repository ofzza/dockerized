#!/bin/bash
#
# Dialog: Message box
# ---------------------------------------------------------------------

# Open dialog with a message box
dialog  --clear --keep-tite \
        --output-fd 1 \
        --msgbox "$1" 10 40
