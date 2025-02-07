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
wget https://raw.githubusercontent.com/thebrentley/jarvis-setup/refs/heads/main/docker-compose.yml

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
wget -P modelfiles https://raw.githubusercontent.com/thebrentley/jarvis-setup/refs/heads/main/modelfile-jarvis-ll3.2-3b.txt 
ollama create jarvis-chat-v0.0.1 -f modelfiles/modelfile-jarvis-ll3.2-3b.txt 

# Bluetooth setup
apt-get install -y bluetooth bluez libbluetooth-dev libudev-dev

# These are optional / for debugging purposes
apt-get install -y net-tools

#cleanup
apt autoremove -y