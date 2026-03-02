FROM	alpine:3.19

RUN	apk update && apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \
	php82-json \
	php82-curl \
	php82-dom \
	php82-exif \
	php82-fileinfo \
	php82-mbstring \
	php82-openssl \
	php82-xml \
	php82-zip \
	php82-phar \
	php82-iconv \
	php82-pecl-redis \
	php82-tokenizer \
	php82-ctype \
	mariadb-client \
	curl

RUN	curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp

RUN	ln -sf /usr/bin/php82 /usr/bin/php

COPY	conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY	tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN	chmod +x /usr/local/bin/wp-setup.sh

WORKDIR	/var/www/html
EXPOSE	9000
RUN	chown -R nobody:nobody /var/www/html

ENTRYPOINT	["sh", "/usr/local/bin/wp-setup.sh"]
