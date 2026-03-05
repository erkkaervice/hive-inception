FROM		alpine:3.22

# Install Redis
RUN			apk update && apk add --no-cache redis

# Ensure the custom config is in the right place
COPY		conf/redis.conf /etc/redis.conf

# Expose the default Redis port
EXPOSE		6379

# Start the server using the custom config and force network flags.
# Runs directly in the foreground using the JSON exec form, naturally
# blocking the terminal as PID 1 without the need for daemonization hacks.
CMD			["redis-server", "/etc/redis.conf", "--protected-mode", "no", "--bind", "0.0.0.0"]
