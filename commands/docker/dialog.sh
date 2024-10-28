#!/bin/bash
#
# Manage server dialog
# ---------------------------------------------------------------------

# Don't exit on errors (needed for dialog tree to work properly)
set +e

# Inherit arguments
NAV_TITLE=$NAV_TITLE
NAV_DESCRIPTION=$NAV_DESCRIPTION
NAVIGATION_PATH_FRIENDLY=$NAVIGATION_PATH_FRIENDLY
NAV_EXEC_ARGS=$NAV_EXEC_ARGS

# Initialize arguments
ARGS_PROCESSED=()
ARGS_UNPROCESSED=(${@:5})

# Preprocess known, static arguments
DOCKER_IMAGE=$(echo $NAV_EXEC_ARGS | jq -r ".dockerimg")
DOCKER_ENV=$(echo $NAV_EXEC_ARGS | jq -r '.dockerenv | to_entries | map(("--env " + .key + "=" + .value)) | join(" ")')

# Preprocess known, static arguments
DOCKER_INSTANCE_NAME=$(echo "ofzza::dockerized::$DOCKER_IMAGE" | sed -e 's/[^A-Za-z0-9_\-]/\-/g' )

# Check if image already installed
NAV_DESCRIPTION_WITH_STATUS=$NAV_DESCRIPTION
DOCKER_IMAGE_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ ! -z "$DOCKER_IMAGE_ID" ]; then
  NAV_DESCRIPTION_WITH_STATUS="$NAV_DESCRIPTION_WITH_STATUS [IMAGE]"
fi

# Check if instance already installed
DOCKER_CONTAINER_ID=$(docker container ls --all --quiet --filter "name=$DOCKER_INSTANCE_NAME")
DOCKER_CONTAINER_STARTED_ID=$(docker container ls --quiet --filter "name=$DOCKER_INSTANCE_NAME")
if [ ! -z "$DOCKER_CONTAINER_ID" ]; then
  if [ -z "$DOCKER_CONTAINER_STARTED_ID" ]; then
    NAV_DESCRIPTION_WITH_STATUS="$NAV_DESCRIPTION_WITH_STATUS [CONTAINER] [STOPPED]"
  else
    NAV_DESCRIPTION_WITH_STATUS="$NAV_DESCRIPTION_WITH_STATUS [CONTAINER] [STARTED]"
  fi
fi

# Initialize actions
SELECT_OPTIONS=()
if [ -z "$DOCKER_IMAGE_ID" ]; then
  SELECT_OPTIONS+=(install "Install")
  SELECT_OPTIONS+=(_uninstall "Uninstall (Not installed)")
else 
  SELECT_OPTIONS+=(_install "Install (Already installed)")
  SELECT_OPTIONS+=(uninstall "Uninstall")
fi
if [ ! -z "$DOCKER_CONTAINER_ID" ]; then
  if [ -z "$DOCKER_CONTAINER_STARTED_ID" ]; then
    SELECT_OPTIONS+=(start "Start")  
    SELECT_OPTIONS+=(_stop "Stop (Not started)")
    SELECT_OPTIONS+=(_connect "Connect (Not started)")
  else
    SELECT_OPTIONS+=(_start "Start (Already started)")  
    SELECT_OPTIONS+=(stop "Stop")
    SELECT_OPTIONS+=(connect "Connect")
  fi
fi

# Select a command
LABEL_OK="Execute"
LABEL_CANCEL="Back"
SELECTED=$(
  dialog  --clear --stdout --keep-tite                            \
          --output-fd 1                                           \
          --backtitle "ofzza"                                     \
          --ok-label "$LABEL_OK"                                  \
          --cancel-label "$LABEL_CANCEL"                          \
          --no-tags --menu "$NAV_DESCRIPTION_WITH_STATUS" 10 80 0 \
          "${SELECT_OPTIONS[@]}"                                  \
)

# If selected action, update navigated path
if [[ $? -eq 0 ]]; then
  # Initialize success and error response variables
  ACTION_OUTPUT=''
  ACTION_OK=''
  ACTION_ERR=''
  
  # Run action
  if [ $SELECTED == "install" ]; then
    # Run install
    ACTION_OUTPUT=$(. $ROOT/commands/$NAV_EXEC/commands/run-install.sh ${ARGS_UNPROCESSED[*]})
    # Check if run successful
    if [[ $? -eq 0 ]]; then ACTION_OK='Installed!'; else ACTION_ERR='Failed installing!'; fi
  elif [ $SELECTED == "uninstall" ]; then
    # Run install
    ACTION_OUTPUT=(. $ROOT/commands/$NAV_EXEC/commands/run-uninstall.sh ${ARGS_UNPROCESSED[*]})
    # Check if run successful
    if [[ $? -eq 0 ]]; then ACTION_OK='Uninstalled!'; else ACTION_ERR='Failed uninstalling!'; fi
  elif [ $SELECTED == "start" ]; then  
    # Run install
    ACTION_OUTPUT=$(. $ROOT/commands/$NAV_EXEC/commands/run-start.sh ${ARGS_UNPROCESSED[*]})
    # Check if run successful
    if [[ $? -eq 0 ]]; then ACTION_OK='Started!'; else ACTION_ERR='Failed starting!'; fi
  elif [ $SELECTED == "stop" ]; then  
    # Run install
    ACTION_OUTPUT=$(. $ROOT/commands/$NAV_EXEC/commands/run-stop.sh ${ARGS_UNPROCESSED[*]})
    # Check if run successful
    if [[ $? -eq 0 ]]; then ACTION_OK='Stopped!'; else ACTION_ERR='Failed stopping!'; fi
  elif [ $SELECTED == "connect" ]; then
    # Run install
    { output=$(. $ROOT/commands/$NAV_EXEC/commands/run-connect.sh -- ${ARGS_UNPROCESSED[*]} 2>&1 1>&3-) ;} 3>&1
    # Check if run successful
    if [[ $? -eq 0 ]]; then ACTION_OK=''; else ACTION_ERR='Failed connecting!'; fi
  fi

  # Display success pr error prompt
  if [ ! -z $ACTION_ERR ]; then
    dialog  --clear --keep-tite \
        --output-fd 1 \
        --msgbox "$ACTION_ERR \n\n $ACTION_OUTPUT" 10 40
  fi

  # (Re)Run same dialog
  . $ROOT/commands/$NAV_EXEC/dialog.sh $NAV_TITLE $NAV_DESCRIPTION $NAVIGATION_PATH_FRIENDLY $NAV_EXEC_ARGS ${ARGS_UNPROCESSED[*]}

# If no selected action and not root path
else
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
fi


# Exit cleanly
exit 0
