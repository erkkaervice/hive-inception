#!/bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]
then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]
then
	cat <<- EOF > /tmp/init.sql
	FLUSH PRIVILEGES;
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
	CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
	CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
	GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
	FLUSH PRIVILEGES;
	EOF
	mysqld --user=mysql --bootstrap < /tmp/init.sql
	rm -f /tmp/init.sql
fi

exec mysqld --user=mysql
