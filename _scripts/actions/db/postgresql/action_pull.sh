#!/bin/bash

# PostgreSQL "pull" action
# ---------------------------------------------------------------------

# Pull latest PostgreSQL docker image
SHA=$(docker pull postgres:latest | grep "Digest:" | cut -d':' -f3)

# Return to previous dialog
. ./scripts/actions/db/postgresql/dialog.sh

