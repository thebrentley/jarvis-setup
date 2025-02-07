#!/bin/bash

# TODO: assume root

# Install core libraries
apt-get update

# Set up docker
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
apt-get install -y docker-compose

# Start docker services
docker-compose up -d

# Create database and permissions
apt-get install -y postgresql-client
echo "SELECT 'CREATE DATABASE jarvis' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'jarvis')\gexec" | psql postgres://jarvis:jarvis@127.0.0.1:5432
apt-get remove -y postgresql-client

# Set up ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pre-pull models
ollama pull deepseek-r1:1.5b
ollama pull llama3.2:3b

# Create model files
mkdir modelfiles
wget  > modelfiles/jarvis-dsr1-1.5b # TODO: wget jarvis files...
ollama create model --name jarvis-reasoning-v0.0.1 -f modelfiles/jarvis-dsr1-1.5b
ollama create model --name jarvis-chat-v0.0.1 -f modelfiles/jarvis-ll3.2-3b

# Bluetooth setup
apt-get install -y bluetooth bluez libbluetooth-dev libudev-dev

# These are optional / for debugging purposes
apt-get install -y net-tools


# Development only
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
apt-get install -y npm
npm install -g yarn
apt-get install -y python3.12