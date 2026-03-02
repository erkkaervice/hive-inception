#!/bin/sh

until mariadb-admin ping -h"mariadb" -u"$MYSQL_USER" -p"$(cat /run/secrets/db_user_password)" --silent; do
	echo "Waiting for MariaDB..."
	sleep 2
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
	rm -rf /var/www/html/*
	php -d memory_limit=1G /usr/local/bin/wp core download --allow-root --path=/var/www/html
	php -d memory_limit=512M /usr/local/bin/wp config create --allow-root \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$(cat /run/secrets/db_user_password) \
		--dbhost=mariadb --path=/var/www/html
	php -d memory_limit=512M /usr/local/bin/wp core install --allow-root \
		--url=$DOMAIN_NAME \
		--title="$WP_TITLE" \
		--admin_user=$WP_ADMIN_USER \
		--admin_password=$(cat /run/secrets/wp_admin_password) \
		--admin_email=$WP_ADMIN_EMAIL --path=/var/www/html
	php -d memory_limit=512M /usr/local/bin/wp user create $WP_USER $WP_USER_EMAIL \
		--role=author --user_pass=$(cat /run/secrets/wp_user_password) --allow-root --path=/var/www/html
fi

echo "Waiting for Redis network connectivity..."
until php -r '$r = new Redis(); try { if (@$r->connect("redis", 6379)) { exit(0); } } catch (Exception $e) {} exit(1);'; do
	echo "Redis not reachable. Retrying..."
	sleep 2
done

if ! php -d memory_limit=512M /usr/local/bin/wp plugin is-installed redis-cache --allow-root --path=/var/www/html; then
	php -d memory_limit=512M /usr/local/bin/wp plugin install redis-cache --activate --allow-root --path=/var/www/html
fi

php -d memory_limit=512M /usr/local/bin/wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/html
php -d memory_limit=512M /usr/local/bin/wp config set WP_REDIS_PORT 6379 --raw --allow-root --path=/var/www/html
php -d memory_limit=512M /usr/local/bin/wp config set WP_REDIS_CLIENT phpredis --allow-root --path=/var/www/html

php -d memory_limit=512M /usr/local/bin/wp redis enable --allow-root --path=/var/www/html

chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
