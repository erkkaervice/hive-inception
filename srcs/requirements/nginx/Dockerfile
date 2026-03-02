FROM	alpine:3.19

# Install NGINX and OpenSSL
RUN	apk update && apk add --no-cache nginx openssl

# Create the SSL directory and generate the self-signed certificate
RUN	mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=eala-lah/CN=eala-lah.42.fr"

# Copy the custom configuration
COPY	conf/default.conf /etc/nginx/http.d/default.conf

# Create the web root directory to avoid permission errors
RUN	mkdir -p /var/www/html

EXPOSE	443

# Run NGINX in the foreground as PID 1
ENTRYPOINT	["nginx", "-g", "daemon off;"]
