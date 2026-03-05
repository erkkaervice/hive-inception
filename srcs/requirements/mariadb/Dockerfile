FROM		alpine:3.22

# Install MariaDB server and client
RUN			apk update && apk add --no-cache mariadb mariadb-client

# Create the socket directory with correct permissions
RUN			mkdir -p /var/run/mysqld && \
			chown -R mysql:mysql /var/run/mysqld && \
			chmod 777 /var/run/mysqld

# Copy configuration and setup script
COPY		conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY		tools/mariadb-setup.sh /usr/local/bin/mariadb-setup.sh
RUN			chmod +x /usr/local/bin/mariadb-setup.sh

# Expose MariaDB port
EXPOSE		3306

# Use the setup script as the entrypoint via the JSON exec form.
# The script must end with 'exec mysqld' to replace the shell process,
# promoting the database daemon to PID 1 without using background loops.
ENTRYPOINT	["sh", "/usr/local/bin/mariadb-setup.sh"]
