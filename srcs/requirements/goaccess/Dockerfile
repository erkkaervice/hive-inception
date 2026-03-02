FROM	alpine:3.19

RUN	apk update && apk add --no-cache goaccess

# Create the web root for the HTML report
RUN	mkdir -p /var/www/html

# Copy the setup script
COPY	tools/goaccess-setup.sh /usr/local/bin/goaccess-setup.sh
RUN	chmod +x /usr/local/bin/goaccess-setup.sh

# GoAccess Web Interface
EXPOSE	7890

# WebSocket port for real-time updates
EXPOSE	7891

ENTRYPOINT	["sh", "/usr/local/bin/goaccess-setup.sh"]
