#!/bin/bash

# This assumes that ./setup.sh has already been run and was successful
# Run as non-root so rsync can work
# Development only
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
apt-get install -y npm
npm install -g yarn
apt-get install -y python3.12