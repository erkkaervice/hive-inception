FROM	alpine:3.19

RUN	apk update && apk add --no-cache redis

# Ensure the config is in the right place
COPY	conf/redis.conf /etc/redis.conf

# Expose the default Redis port
EXPOSE	6379

# Start the server using the custom config AND force the network flags
CMD	["redis-server", "/etc/redis.conf", "--protected-mode", "no", "--bind", "0.0.0.0"]
