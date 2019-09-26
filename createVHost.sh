#!/bin/bash
# VirtualHost für Domain erstellen (falls noch nicht passiert)
# source https://www.webhosterwissen.de/know-how/eigener-webserver/tutorial-apache-virtual-hosts-anlegen/
 
# Schritt 1 = domain, directory und public directory abfragen
if [ -z $1 ]; then
    echo Name the new domain.
    read -p "Domain: " DOMAIN 
else
    DOMIAN=$1
    echo Domain: $DOMAIN
fi

echo Should the projectfolder has the name $DOMAIN \[Y/n\]
read selection

if [ $selection != 'Y' ]; then
    read -p 'Project Directory: ' DIR
else
    DIR=$DOMAIN
    echo Projects Directory: $DIR
fi

DIR=/var/www/win/$DIR

read -p "Please enter the public directory relativ to the project directory [$DIR]: " PUB_DIR
if [ -z $PUB_DIR ]; then
    PUB_DIR=$DIR
else
    PUB_DIR=$DIR/$PUB_DIR
fi    

echo Public Directory: $PUB_DIR

# Schritt 2 - Verzeichnis erstellen und Rechte anpassen
if [ -d $DIR ]; then
   echo "Existing $DIR will be used."
else
    sudo mkdir $DIR
fi

# Schritt 3 - Apache Config-Datei für domain.de erstellen
printf "
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $PUB_DIR
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
			 
<Directory $PUB_DIR/>
    AllowOverride All
</Directory>" | sudo tee /etc/apache2/sites-available/$DOMAIN.conf
			 
# Schritt 3 - VirtualHost Konfiguration für Domain aktivieren
sudo a2ensite $DOMAIN.conf
sudo service apache2 reload

