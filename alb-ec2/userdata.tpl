#!/bin/bash
sudo apt update -y
sudo apt install apache2 git -y
sudo rm -rf /var/www/html
echo "Your IP address is: <?php echo $_SERVER["REMOTE_ADDR"]; ?>" > /var/www/html/index.html
sudo systemctl restart apache2