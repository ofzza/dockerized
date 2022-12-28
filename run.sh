#!/bin/bash
#
# Entry point
# ---------------------------------------------------------------------

# Get script root directory
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Exit on any error
set -e
function cleanup {
  set +e
}
trap cleanup EXIT

# Variables
IFS=""
DIALOG_TITLE="Dockerize"

# Check if dialog installed
if ! command -v dialog  &> /dev/null
then
  # Prompt dialog not installed
  echo "CLI utility 'dialog' does not seem to be installed on your system! This script can attempt to install it for you."
  echo "Note: For Debian based systems only supporting 'apt'. Should be run as 'sudo'."
  echo
  echo "Alternatively you can install the utility yourself and rerun this script ..."

  # Wait for confirmation
  read -r -p "Install 'dialog'? (Y/n) " response
  case "$response" in
    [yY][eE][sS]|[yY])       
      # Attempt to install dialog
      . ./install/install-dialog.sh
      # If installation failed, exit
      test [$? -eq 0] || exit
    ;;
    *)
      # If no confirmation, exit
      exit 1
    ;;
  esac
fi

# Check if jq installed
if ! command -v jq  &> /dev/null
then
  # Prompt jq not installed
  echo "CLI utility 'jq' does not seem to be installed on your system! This script can attempt to install it for you."
  echo "Note: For Debian based systems only supporting 'apt'. Should be run as 'sudo'."
  echo
  echo "Alternatively you can install the utility yourself and rerun this script ..."

  # Wait for confirmation
  read -r -p "Install 'jq'? (Y/n) " response
  case "$response" in
    [yY][eE][sS]|[yY])       
      # Attempt to install jq
      . ./install/install-jq.sh
      # If installation failed, exit
      test [$? -eq 0] || exit
    ;;
    *)
      # If no confirmation, exit
      exit 1
    ;;
  esac
fi

# Check if docker installed
if ! command -v docker version &> /dev/null
then
  # Prompt docker not installed
  echo "Docker does not seem to be installed on your system! This script can attempt to install it for you."
  echo "Note: For Debian based systems only supporting 'apt'. Should be run as 'sudo'."
  echo
  echo "Alternatively you can install docker yourself and rerun this script ..."

  # Wait for confirmation
  read -r -p "Install 'docker'? (Y/n) " response
  case "$response" in
    [yY][eE][sS]|[yY])       
      # Attempt to install docker
      . ./install/install-docker.sh
      # If installation failed, exit
      test [$? -eq 0] || exit
    ;;
    *)
      # If no confirmation, exit
      exit 1
    ;;
  esac
fi

# Process commands or display dialog
. "$ROOT/commands/run.sh"
