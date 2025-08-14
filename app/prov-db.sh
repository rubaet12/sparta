#!/bin/bash
# Script for the database

echo "Updating and upgrading system..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo "System update & upgrade complete."
echo

echo "Installing prerequisites (gnupg, curl)..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg curl
echo "Prerequisites installed."
echo

echo "Importing MongoDB public key..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-server-7.0.gpg > /dev/null
echo "Public key imported."
echo

echo "Creating MongoDB APT source list..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
| sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null
echo "Source list file created."
echo

echo "Reloading package list..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
echo "Package list reloaded."
echo

echo "Installing MongoDB 7.0.22..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
   mongodb-org=7.0.22 \
   mongodb-org-database=7.0.22 \
   mongodb-org-server=7.0.22 \
   mongodb-mongosh \
   mongodb-org-shell=7.0.22 \
   mongodb-org-mongos=7.0.22 \
   mongodb-org-tools=7.0.22 \
   mongodb-org-database-tools-extra=7.0.22
echo "MongoDB installed."
echo

echo "Configuring MongoDB to allow external connections..."
sudo cp /etc/mongod.conf /etc/mongod.conf.bk
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
echo "bindIp updated to 0.0.0.0"
echo

echo "Starting and enabling MongoDB service..."
sudo systemctl start mongod
sudo systemctl enable mongod
echo "MongoDB is running."
