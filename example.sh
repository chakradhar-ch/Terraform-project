#!/bin/bash
sudo su - root
sudo apt-get update && apt-get install apache2 -y
git clone https://github.com/amolshete/card-website.git
rm /var/www/html/index.html
cp /card-website/* /var/www/html/


