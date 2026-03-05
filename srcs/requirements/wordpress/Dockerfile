FROM		alpine:3.22

# Install PHP 8.2, necessary extensions, MariaDB client, and curl
RUN			apk update && apk add --no-cache \
			php82 php82-fpm php82-mysqli php82-json php82-curl \
			php82-dom php82-exif php82-fileinfo php82-mbstring \
			php82-openssl php82-xml php82-zip php82-phar \
			php82-iconv php82-pecl-redis php82-tokenizer \
			php82-ctype mariadb-client curl

# Download and install WP-CLI
RUN			curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
			chmod +x /usr/local/bin/wp

# Create a symlink so 'php' command works
RUN			ln -sf /usr/bin/php82 /usr/bin/php

# Copy the PHP-FPM configuration and setup script
COPY		conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY		tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN			chmod +x /usr/local/bin/wp-setup.sh

# Set up the web root and ensure proper ownership
WORKDIR		/var/www/html
RUN			chown -R nobody:nobody /var/www/html

# Expose PHP-FPM port
EXPOSE		9000

# Use the setup script as the entrypoint via the JSON exec form.
# The script must end with 'exec php-fpm82 -F' to replace the shell process,
# keeping the FastCGI manager in the foreground as PID 1.
ENTRYPOINT	["sh", "/usr/local/bin/wp-setup.sh"]
