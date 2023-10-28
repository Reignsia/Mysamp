#!/bin/bash

# This script installs Open Game Panel on Debian 11.

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Install necessary packages
apt-get update
apt-get install -y apache2 curl subversion php7.4 php7.4-gd php7.4-zip libapache2-mod-php7.4 php7.4-curl php7.4-mysql php7.4-xmlrpc php-pear mariadb-server php7.4-mbstring git php-bcmath

# Configure MariaDB bind-address
read -p "Enter the MariaDB bind address (default: 0.0.0.0): " db_bind_address
db_bind_address="${db_bind_address:-0.0.0.0}"
sed -i "s/^bind-address.*/bind-address=$db_bind_address/g" "/etc/mysql/mariadb.conf.d/50-server.cnf"

# Install phpMyAdmin
read -p "Do you want to install phpMyAdmin? (y/n): " install_phpmyadmin
if [ "$install_phpmyadmin" = "y" ]; then
    apt-get install -y phpmyadmin
fi

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

# Clean up
rm "ogp-panel-latest.deb" "ogp-agent-latest.deb"

# Display credentials
echo "Open Game Panel has been installed. You can access it through your web browser."

# Display credentials
sudo cat /root/ogp_user_password
sudo cat /root/ogp_panel_mysql_info