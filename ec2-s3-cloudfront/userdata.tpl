#!/bin/bash
sudo apt update -y
sudo apt install apache2 git -y
sudo rm -rf /var/www/html
git clone https://github.com/Darlene-Naz/Darlene-Naz.github.io /var/www/html/
sudo systemctl restart apache2