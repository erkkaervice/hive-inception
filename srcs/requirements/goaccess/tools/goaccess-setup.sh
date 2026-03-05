#!/bin/sh

# Wait for WordPress to finish its installation and directory wipe.
while [ ! -f /var/www/html/wp-config.php ]; do
    echo "Waiting for WordPress installation to complete..."
    sleep 2
done

# Wait until NGINX physically creates the log file.
while [ ! -f /var/log/nginx/access.log ]; do
    echo "Waiting for NGINX access.log..."
    sleep 2
done

# Force create the report file safely after the wipe.
touch /var/www/html/report.html
chmod 777 /var/www/html/report.html

echo "Starting GoAccess..."

# The 'exec' command is strictly required here. It instructs the Linux kernel to 
# completely destroy this running shell script and replace it with the goaccess daemon. 
# This promotes goaccess directly to PID 1, ensuring the service stays natively locked 
# in the foreground without background loops, and properly catches SIGTERM signals.
exec goaccess /var/log/nginx/access.log \
    --log-format=COMBINED \
    --real-time-html \
    --output=/var/www/html/report.html \
    --addr=0.0.0.0 \
    --port=7890 \
    --ws-url=wss://eala-lah.42.fr:443/ws
