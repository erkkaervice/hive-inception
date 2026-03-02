#!/bin/sh

# 1. Wait for WordPress to finish its installation and directory wipe
while [ ! -f /var/www/html/wp-config.php ]; do
	echo "Waiting for WordPress installation to complete..."
	sleep 2
done

# 2. Wait until NGINX physically creates the log file
while [ ! -f /var/log/nginx/access.log ]; do
	echo "Waiting for NGINX access.log..."
	sleep 2
done

# 3. Force create the report file safely after the wipe
touch /var/www/html/report.html
chmod 777 /var/www/html/report.html

echo "Starting GoAccess..."
exec goaccess /var/log/nginx/access.log \
	--log-format=COMBINED \
	--real-time-html \
	--output=/var/www/html/report.html \
	--addr=0.0.0.0 \
	--port=7890 \
	--ws-url=wss://eala-lah.42.fr:443/ws
