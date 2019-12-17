#!/bin/bash
# VirtualHost für Domain erstellen (falls noch nicht passiert)
# source https://www.webhosterwissen.de/know-how/eigener-webserver/tutorial-apache-virtual-hosts-anlegen/

if [ -z $APACHE_LOG_DIR ]; then
  APACHE_LOG_DIR='/var/www/log'
fi

# Schritt 1 = domain, directory und public directory abfragen
if [ -z $1 ]; then
    echo Name the new domain.
    read -p "Domainame (without .tdl): " DOMAIN_NAME
else
    DOMAIN_NAME=$1
    echo "Domainame (without .tdl): $DOMAIN_NAME"
fi

echo Should the projectfolder has the name $DOMAIN_NAME \[Y/n\]
read selection

if [ $selection != 'Y' ]; then
    read -p 'Project Directory: ' DIR
else
    DIR=$DOMAIN_NAME
    echo Projects Directory: $DIR
fi

DIR=/var/www/html/$DIR
DOMAIN="$DOMAIN_NAME.test"

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

# Schritt 3 create self singed cert
cd ~/ssl-certs
mkcert $DOMAIN


# Schritt 4 - Apache Config-Datei für domain.de erstellen
echo "create config file: /etc/apache2/sites-available/$DOMAIN.conf"
printf "
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $PUB_DIR
    ErrorLog ${APACHE_LOG_DIR}/$DOMAIN_NAME-error.log
    CustomLog ${APACHE_LOG_DIR}/$DOMAIN_NAME-access.log combined
</VirtualHost>
			 
<Directory $PUB_DIR/>
    AllowOverride All
</Directory>
" | sudo tee /etc/apache2/sites-available/$DOMAIN.conf

echo "create config file: /etc/apache2/sites-available/$DOMAIN-ssl.conf"
printf "<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin admin@$DOMAIN
        ServerName $DOMAIN
        ServerAlias www.$DOMAIN
        DocumentRoot $PUB_DIR

        <Directory $PUB_DIR/>
            AllowOverride all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/$DOMAIN_NAME-error.log
        CustomLog ${APACHE_LOG_DIR}/$DOMAIN_NAME-access.log combined

        SSLEngine on

        SSLCertificateFile  $HOME/ssl-certs/$DOMAIN.pem
        SSLCertificateKeyFile $HOME/ssl-certs/$DOMAIN-key.pem

        <FilesMatch \"\\.(cgi|shtml|phtml|php)$\">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>

    </VirtualHost>
</IfModule>
" | sudo tee /etc/apache2/sites-available/$DOMAIN-ssl.conf

# Schritt 5 - VirtualHost Konfiguration für Domain aktivieren
sudo a2ensite $DOMAIN.conf
sudo a2ensite $DOMAIN-ssl.conf
sudo service apache2 reload

# Schritt 6 - add new url to hosts file

echo "127.0.0.1  $DOMAIN
127.0.0.1  www.$DOMAIN
" | sudo tee -a /etc/hosts > /dev/null