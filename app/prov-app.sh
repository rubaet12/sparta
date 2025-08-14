#!/bin/bash

# Provisioning Script

echo "update..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update
echo "update done"
echo

echo "upgrade..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo "upgrade done"
echo

echo "install nginx..."
sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y
echo "nginx install complete"
echo

# Configure Nginx as reverse proxy
echo "Configuring Nginx reverse proxy..."

# Backup default config
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# Replace try_files line with proxy_pass
sudo sed -i 's|try_files.*|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

# Restart nginx to apply changes
sudo systemctl restart nginx
echo "Nginx reverse proxy configured and restarted"
echo

echo "install node.js..."
sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
echo "node.js install complete"
echo

# Install PM2 globally
echo "installing pm2..."
sudo npm install -g pm2
echo "pm2 install complete"
echo

echo "cloning git repo..."
git clone https://github.com/rubaet12/sparta.git repo
cd repo/app
echo "git cloning complete"
echo

echo "installing npm dependencies..."
npm install
echo "npm install complete"
echo

# Set MongoDB environment variable
export DB_HOST=mongodb://172.31.31.106:27017/posts
echo "db_host is set"
echo


# Start app with PM2
echo "Starting app with PM2..."
pm2 kill # Ensure no old PM2 processes are running
pm2 start app.js --name "sparta-app" # Assuming app.js is the main entry file
pm2 save
echo "App started with PM2."

# Configure PM2 to start on reboot
echo "Configuring PM2 startup..."
sudo pm2 startup systemd
echo "PM2 startup configured."