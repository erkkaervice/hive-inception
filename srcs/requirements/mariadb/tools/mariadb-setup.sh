#!/bin/sh

# Ensure the ownership of the data directory
chown -R mysql:mysql /var/lib/mysql

# Initialize the database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Create initialization script if the target database doesn't exist
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
	cat << EOF > /tmp/init.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_user_password)';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF
	# Run MariaDB in bootstrap mode to apply the SQL commands
	/usr/bin/mysqld --user=mysql --bootstrap < /tmp/init.sql
	rm -f /tmp/init.sql
fi

echo "MariaDB starting..."
exec /usr/bin/mysqld --user=mysql --console
