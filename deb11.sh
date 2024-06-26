#!/bin/bash

# Install necessary packages
apt-get update
apt-get install -y apache2 curl subversion php7.4 php7.4-gd php7.4-zip libapache2-mod-php7.4 php7.4-curl php7.4-mysql php7.4-xmlrpc php-pear mariadb-server php7.4-mbstring git php-bcmath

# Configure MariaDB bind-address
sed -i "s/^bind-address.*/bind-address=0.0.0.0/g" "/etc/mysql/mariadb.conf.d/50-server.cnf"

# Install phpMyAdmin
apt-get install -y phpmyadmin

# Download and install OGP panel
wget -N "https://github.com/OpenGamePanel/Easy-Installers/raw/master/Linux/Debian-Ubuntu/ogp-panel-latest.deb" -O "ogp-panel-latest.deb"
dpkg -i "ogp-panel-latest.deb"

# Install additional packages
apt-get install -y libxml-parser-perl libpath-class-perl perl-modules screen rsync sudo e2fsprogs unzip subversion pure-ftpd libarchive-zip-perl libc6 libgcc1 git curl
apt-get install -y libc6-i386
apt-get install -y lib32gcc1
apt-get install -y lib32gcc-s1
apt-get install -y libhttp-daemon-perl
apt-get install -y libarchive-extract-perl

# Enable 32-bit architecture
dpkg --add-architecture i386
apt-get update
apt-get install -y libstdc++6:i386

# Download and install OGP agent
wget -N "https://github.com/OpenGamePanel/Easy-Installers/raw/master/Linux/Debian-Ubuntu/ogp-agent-latest.deb" -O "ogp-agent-latest.deb"
dpkg -i "ogp-agent-latest.deb"

# Configure PHP settings
sudo sed -i 's/^post_max_size = 8M/post_max_size = 900M/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 900M/' /etc/php/7.4/apache2/php.ini

# Configure Apache for phpMyAdmin
sudo sed -i '$a Alias /phpmyadmin /usr/share/phpmyadmin' /etc/apache2/sites-available/000-default.conf

# Set up cron job for cache dropping
(crontab -l 2>/dev/null; echo "0 * * * * echo 3 > /proc/sys/vm/drop_caches") | crontab -

# Clone and configure theme for OGP
cd /var/www/html/themes/
git clone https://github.com/hmrserver/Obsidian.git
mv Obsidian/themes/Obsidian/* Obsidian/
rmdir Obsidian/themes/Obsidian

# Secure MariaDB installation
sudo mysql_secure_installation

# Enable and restart services
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl enable ogp_agent
sudo systemctl enable mariadb
sudo systemctl enable mysql

# Install and configure fail2ban
sudo apt update
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo cp /etc/fail2ban/jail.local /etc/fail2ban/jail.local.bak

# Configure fail2ban jail.local
sudo sed -i '$a [DEFAULT]\nbantime = 600\nmaxretry = 50\nfindtime = 600\n' /etc/fail2ban/jail.local
sudo sed -i '$a [tcp-iptables]\nenabled = true\nfilter = tcp-iptables\naction = iptables[name=TCP, port=all, protocol=tcp]\nlogpath = /var/log/auth.log\n' /etc/fail2ban/jail.local
sudo sed -i '$a [udp-iptables]\nenabled = true\nfilter = udp-iptables\naction = iptables[name=UDP, port=all, protocol=udp]\nlogpath = /var/log/auth.log\n' /etc/fail2ban/jail.local

# Create fail2ban filters
sudo bash -c 'cat > /etc/fail2ban/filter.d/tcp-iptables.conf <<EOL
[Definition]
failregex = .*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*
ignoreregex =
EOL'

sudo bash -c 'cat > /etc/fail2ban/filter.d/udp-iptables.conf <<EOL
[Definition]
failregex = .*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*
ignoreregex =
EOL'

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

# Display credentials
sudo cat /root/ogp_user_password
sudo cat /root/ogp_panel_mysql_info
