#!/bin/bash
# install-nginx.sh
# Run this script on the private EC2 instance after connecting via SSH tunnel
# Usage: bash install-nginx.sh

set -e

echo "==> Updating package list..."
sudo apt update && sudo apt upgrade -y

echo "==> Installing Nginx..."
sudo apt install nginx -y

echo "==> Starting Nginx..."
sudo systemctl start nginx

echo "==> Enabling Nginx on boot..."
sudo systemctl enable nginx

echo "==> Checking Nginx status..."
sudo systemctl status nginx --no-pager

echo ""
echo "✓ Nginx installed and running."
echo "  Access it from the Bastion via: curl http://10.0.1.235"
