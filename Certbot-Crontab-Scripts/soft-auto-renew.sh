#!/bin/bash

# Stop Apache2 and Nginx services
sudo systemctl stop nginx
sudo systemctl stop apache2 # I don't know, but sometimes apache2 is installed for no reason.
sudo service apache2 stop
sudo service nginx stop
sleep 2
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
# Wait for 5 seconds
sleep 5
# Stopping Nginx services
sudo systemctl stop nginx
sudo systemctl stop apache2 # I don't know, but sometimes apache2 is installed for no reason.
sudo service apache2 stop
sudo service nginx stop
sleep 2
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
# Wait for 5 seconds
sleep 5
# Run Certbot force renew command
sudo certbot renew
# Wait for 10 seconds
sleep 10
# Start Nginx services
sudo systemctl start nginx
# Wait for 3 seconds
sleep 3
# Start Apache2 services
sudo systemctl start apache2