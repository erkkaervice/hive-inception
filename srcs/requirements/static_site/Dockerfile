FROM		alpine:3.22

# Install Python 3
RUN			apk update && apk add --no-cache python3

# Ensure the web root directory exists
RUN			mkdir -p /var/www/html

# Copy the specific index file
COPY		conf/index.html /var/www/html/index.html

WORKDIR		/var/www/html

# Expose the port for documentation purposes
EXPOSE		8081

# Run the Python built-in HTTP server using the JSON exec form.
# Python natively handles requests in the foreground, perfectly satisfying the PID 1 rule.
CMD			["python3", "-m", "http.server", "8081"]
