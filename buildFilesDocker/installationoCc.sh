#!/bin/bash

apt update && \
  apt upgrade -y

#Create the occ Helper Script

FILE="/usr/local/bin/occ"
cat <<EOM >$FILE
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM
chmod +x $FILE

#Install required packages

apt install -y \
  apache2 \
  libapache2-mod-php \
  mariadb-server \
  openssl redis-server wget \
  php-imagick php-common php-curl \
  php-gd php-imap php-intl \
  php-json php-mbstring php-mysql \
  php-ssh2 php-xml php-zip \
  php-apcu php-redis php-ldap \
  php-opcache
  
#Install recommmended Packages

apt install -y \
  unzip bzip2 rsync curl jq \
  inetutils-ping  ldap-utils\
  smbclient
  
#Configure Apache and create a virtual Host Configuration

FILE="/etc/apache2/sites-available/owncloud.conf"
cat <<EOM >$FILE
<VirtualHost *:80>
# ServerName <add a valid ServerName> and uncommment
DirectoryIndex index.php index.html
DocumentRoot /var/www/owncloud
<Directory /var/www/owncloud>
  Options +FollowSymlinks -Indexes
  AllowOverride All
  Require all granted

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
</VirtualHost>
EOM

#Enable the Configuration

a2dissite 000-default
a2ensite owncloud.conf

#Enable recommended Apache Modules

echo "Enabling Apache Modules"
a2enmod dir env headers mime rewrite setenvif

#Download latest Version of ownCloud

cd /var/www/
wget -q https://download.owncloud.org/community/owncloud-complete-latest.tar.bz2 && \
tar -xjf owncloud-complete-latest.tar.bz2 && \
#Ensure that permissions are correct
chown -R www-data. owncloud

#Sets Up a Cron Job

echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data

#Configure Log Rotation

FILE="/etc/logrotate.d/owncloud"
sudo cat <<EOM >$FILE
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM
