#!/bin/bash

# source: https://stackoverflow.com/questions/33470753/create-mysql-database-and-user-in-bash-script 

read -p "Database: " DB
read -p "User: " USER
echo "Password: "
read -s PASSWD

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	mysql -e "CREATE DATABASE ${DB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	mysql -e "CREATE USER ${USER}@localhost IDENTIFIED BY '${PASSWD}';"
	mysql -e "GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"

	# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
	echo "Please enter root user MySQL password!"
	echo "Note: password will be hidden when typing"
	read -s rootpasswd
	sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${DB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
	sudo mysql -uroot -p${rootpasswd} -e "CREATE USER ${USER}@localhost IDENTIFIED BY '${PASSWD}';"
	sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';"
	sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
