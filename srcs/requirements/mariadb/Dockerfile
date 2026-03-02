FROM	alpine:3.19

RUN	apk update && apk add --no-cache mariadb mariadb-client

# Create the socket directory with correct permissions
RUN	mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld

# Copy configuration and setup script
COPY	conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY	tools/mariadb-setup.sh /usr/local/bin/mariadb-setup.sh

RUN	chmod +x /usr/local/bin/mariadb-setup.sh

# Expose MariaDB port
EXPOSE	3306

# Use the setup script as entrypoint
ENTRYPOINT	["sh", "/usr/local/bin/mariadb-setup.sh"]
