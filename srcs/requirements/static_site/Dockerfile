FROM    alpine:3.19

RUN     apk update && apk add --no-cache python3

# Ensure the directory exists
RUN     mkdir -p /var/www/html

# Copy the specific index file
COPY    conf/index.html /var/www/html/index.html

WORKDIR /var/www/html

# Expose the port for documentation purposes
EXPOSE  8081

# Run the Python built-in HTTP server
CMD     ["python3", "-m", "http.server", "8081"]
