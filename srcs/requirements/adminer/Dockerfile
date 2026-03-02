FROM	alpine:3.19

# Install PHP 8.2 and necessary extensions for Adminer
RUN	apk update && apk add --no-cache \
	php82 \
	php82-session \
	php82-mysqli \
	php82-pdo_mysql \
	wget

# Create a symlink so 'php' command works
RUN	ln -sf /usr/bin/php82 /usr/bin/php

# Set up the web root
RUN	mkdir -p /var/www/html

# Download the latest stable Adminer version
RUN	wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

WORKDIR	/var/www/html

# Adminer Port
EXPOSE	8080

# Start the PHP built-in web server
CMD	["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
