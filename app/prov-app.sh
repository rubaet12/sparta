#!/bin/bash
 
#Provision
 
echo "update..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update
echo "update done"
echo
 
echo "upgrade..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
echo "upgrade done"
echo
 
echo "install ngnix..."
sudo DEBIAN_FRONTEND=noninteractive apt install nginx -y
echo "nginx install complete"
echo
 
sudo cp /etc/nginx/sites-available/default/etc/nginx/sites-available/default.bak
 
# Update nginx config to reverse proxy to port 3000
sudo sed -i '/^\s*try_files/c\        proxy_pass http://localhost:3000;' /etc/nginx/sites-available/default
 
# Restart nginx
sudo systemctl restart nginx
 
echo "install node.js..."
sudo DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
echo "node.js install complete"
echo
 
echo "cloning git..."
git clone https://github.com/rubaet12/sparta.git repo
echo "git cloning complete"
echo
 
echo
cd repo/app
echo "changed to app directory"
 
echo
export DB_HOST=mongodb://172.31.23.78:27017/posts
echo "DB_HOST is set"
echo
 
echo "installing npm..."
npm install
echo "npm install complete"
echo
 
 
# # this helps to make it idempotent by checking for port 3000 running and if it is running it will kill the process and start it again
# echo " Checking if anything is already using port 3000..."
# PID=$(sudo lsof -t -i:3000 || true)
# if [ -n "$PID" ]; then
#   echo " Port 3000 is in use by PID $PID. Killing..."  
#   sudo kill $PID
#   echo " Port 3000 cleared."
# else
#   echo " Port 3000 is free."
# fi
# echo
 
# Global installation of pm2
echo "installing pm2..."
npm install -g pm2
echo "pm2 install complete"
echo
 
echo "Ensuring pm2 process idempotent"
pm2 delete sparta-app || true
echo
 
#start pm2
echo "Starting app..."
pm2 start npm --name "tech508-sparta-app" -- start
pm2 save
echo "App has started in background!"
echo
 
# start npm
# echo "Starting app..."
# npm start &
# echo "App has started in background!"
# echo