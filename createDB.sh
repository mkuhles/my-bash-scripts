#!/bin/bash

MAINDB=$1
PASSWDDB=$1

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	mysql -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	mysql -e "CREATE USER ${MAINDB}@localhost IDENTIFIED BY '${PASSWDDB}';"
	mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINDB}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"

	# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
	echo "Please enter root user MySQL password!"
	echo "Note: password will be hidden when typing"
	read -s rootpasswd
	sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	sudo mysql -uroot -p${rootpasswd} -e "CREATE USER ${MAINDB}@localhost IDENTIFIED BY '${PASSWDDB}';"
	sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINDB}'@'localhost';"
	sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
