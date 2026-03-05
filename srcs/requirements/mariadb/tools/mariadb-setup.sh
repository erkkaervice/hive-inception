#!/bin/sh

# Ensure the ownership of the data directory is correct for the mysql user.
chown -R mysql:mysql /var/lib/mysql

# Initialize the database file structure if it is not already present.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Create initialization script if the target database doesn't exist.
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

    # Run MariaDB in bootstrap mode to apply the SQL commands without starting the network daemon.
    /usr/bin/mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
fi

echo "MariaDB starting..."

# The 'exec' command is strictly required here. It instructs the Linux kernel to 
# completely destroy this running shell script and replace it with the mysqld daemon. 
# This promotes mysqld directly to PID 1, ensuring the service stays natively locked 
# in the foreground without background loops, and properly catches SIGTERM signals.
exec /usr/bin/mysqld --user=mysql --console
