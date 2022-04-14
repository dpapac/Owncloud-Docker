#!/bin/bash

#Install unzip
sudo apt install unzip

#Change into repositroy the example will be stored in 
cd /var/www/owncloud/apps-external

#Download the theme 
wget https://github.com/owncloud/theme-example/archive/master.zip

#Extract 
unzip master.zip

#Rename theme
mv theme-example-master dockerThemes

#Rename it in /dockerThemes/appinfo/info.xml
sed -i "s#<id>theme-example<#<id>dockerThemes<#" "dockerThemes/appinfo/info.xml"

#Adjust the permissions
sudo chown -R www-data: dockerThemes

#Enable Themes
occ app:enable dockerThemes

#Avoid a signature warning in the ownCloud UI
cat << EOF >> /var/www/owncloud/config/config.php
'integrity.ignore.missing.app.signature' => [
       'dockerThemes',
],
EOF

