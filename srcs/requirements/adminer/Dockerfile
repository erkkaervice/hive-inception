FROM		alpine:3.22

# Install PHP 8.2 and necessary extensions for Adminer
RUN			apk update && apk add --no-cache \
			php82 php82-session php82-mysqli php82-pdo_mysql wget

# Create a symlink so 'php' command works
RUN			ln -sf /usr/bin/php82 /usr/bin/php

# Set up the web root
RUN			mkdir -p /var/www/html

# Download the latest stable Adminer version
RUN			wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

WORKDIR		/var/www/html

# Expose Adminer Port
EXPOSE		8080

# Start the PHP built-in web server in the foreground via the JSON exec form.
# It natively blocks the terminal waiting for requests, securely holding PID 1.
CMD			["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
