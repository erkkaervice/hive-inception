FROM	alpine:3.19

RUN	apk update && apk add --no-cache nginx openssl

RUN	mkdir -p /etc/nginx/ssl
RUN	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=eala-lah/CN=eala-lah.42.fr"

COPY	conf/default.conf /etc/nginx/http.d/default.conf

EXPOSE	443

ENTRYPOINT	["nginx", "-g", "daemon off;"]
