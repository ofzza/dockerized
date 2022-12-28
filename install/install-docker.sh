#!/bin/bash

# Install docker deps (https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9)
# ---------------------------------------------------------------------
sudo apt install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg2
# Add docker repo
curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
# Install docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
# Add user to docker group
sudo usermod -aG docker $USER
# Create docker socket
DOCKER_DIR=/mnt/wsl/shared-docker
mkdir -pm o=,ug=rwx "$DOCKER_DIR"
chgrp docker "$DOCKER_DIR"
# Configure docker socket
mkdir -p /etc/docker
cat <<EOT >> /etc/docker/daemon.json
{
  "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"],
  "iptables": false
}
EOT
