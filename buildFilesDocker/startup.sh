#!/bin/bash

#Variables

installed=true
installationStatus=$(occ status --output json | jq .installed)

#Install Owncloud only if the output of the status .installed is false

if [[ "$installationStatus" != "$installed" ]] 
  then
#Restart database to ensure process is working
/etc/init.d/mysql restart
sleep 5

#Configure the Database
mysql<<EOF
 CREATE USER IF NOT EXISTS 'dbadmin'@'localhost' IDENTIFIED BY 'password';
 GRANT ALL PRIVILEGES ON *.* TO 'dbadmin'@'localhost' WITH GRANT OPTION;
 FLUSH PRIVILEGES;
 SHOW GRANTS FOR 'dbadmin'@'localhost';
 exit
EOF

#For occ maintenance Restart Apache2 and Redis-Server
/etc/init.d/redis-server restart
/etc/init.d/apache2 restart
sleep 5

#Install ownCloud
occ maintenance:install \
    --database "mysql" \
    --database-name "owncloud" \
    --database-user "dbadmin" \
    --database-pass "password" \
    --data-dir "/var/www/owncloud/data" \
    --admin-user "admin" \
    --admin-pass "admin"

#Configure ownCloud's Trusted Domains

myip=$(hostname -I|cut -f1 -d ' ')
occ config:system:set trusted_domains 1 --value="$myip"

#Set background job mode to cron

occ background:cron

#Configure Caching and File Locking

occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

echo "The installation was finished, your current installed Version is:"
occ status

#Loop for processes 
while true ; do sleep 900 ; done

else 
    while true 
    do
      sleep 90000
    done 
fi 
