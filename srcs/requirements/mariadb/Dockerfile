FROM	alpine:3.19

RUN	apk update && apk add --no-cache mariadb mariadb-client

RUN	mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	chmod 755 /var/run/mysqld

COPY	conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY	tools/mariadb-setup.sh /usr/local/bin/mariadb-setup.sh

RUN	chmod +x /usr/local/bin/mariadb-setup.sh

EXPOSE	3306

ENTRYPOINT	["sh", "/usr/local/bin/mariadb-setup.sh"]
