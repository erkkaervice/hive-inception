FROM		alpine:3.22

# Install GoAccess
RUN			apk update && apk add --no-cache goaccess

# Create the web root for the HTML report
RUN			mkdir -p /var/www/html

# Copy and prepare the setup script
COPY		tools/goaccess-setup.sh /usr/local/bin/goaccess-setup.sh
RUN			chmod +x /usr/local/bin/goaccess-setup.sh

# Expose GoAccess Web Interface and WebSocket ports
EXPOSE		7890
EXPOSE		7891

# Run the setup script via the JSON exec form.
# The script must end with 'exec goaccess <flags>' to replace the shell process,
# keeping the analyzer running strictly as PID 1.
ENTRYPOINT	["sh", "/usr/local/bin/goaccess-setup.sh"]
