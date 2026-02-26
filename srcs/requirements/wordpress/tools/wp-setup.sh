#!/bin/sh

# Ensure the bin directory exists
mkdir -p /usr/local/bin

# 1. Install WP-CLI first so it's guaranteed to be there
if [ ! -f "/usr/local/bin/wp" ]; then
	curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
fi

# Wait for MariaDB
until mariadb-admin ping -h"mariadb" -u"root" -p"$(cat /run/secrets/db_root_password)" --silent; do
	echo "Waiting for MariaDB..."
	sleep 2
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
	rm -rf /var/www/html/*

	php -d memory_limit=1G /usr/local/bin/wp core download --allow-root --path=/var/www/html

	php -d memory_limit=512M /usr/local/bin/wp config create --allow-root \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$(cat /run/secrets/db_password) \
		--dbhost=mariadb --path=/var/www/html

	php -d memory_limit=512M /usr/local/bin/wp core install --allow-root \
		--url=$DOMAIN_NAME \
		--title="$WP_TITLE" \
		--admin_user=$WP_ADMIN_USER \
		--admin_password=$(cat /run/secrets/credentials.txt) \
		--admin_email=$WP_ADMIN_EMAIL --path=/var/www/html

	php -d memory_limit=512M /usr/local/bin/wp user create $WP_USER $WP_USER_EMAIL \
		--role=author --user_pass=$WP_USER_PASSWORD --allow-root --path=/var/www/html
fi

chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "WordPress is ready. Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
