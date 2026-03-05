FROM		alpine:3.22

# Install socat and fortune from standard repos, and cowsay from the testing repo
RUN			apk update && apk add --no-cache socat fortune && \
			apk add --no-cache cowsay --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

# Expose Cowsay TCP port
EXPOSE		4243

# Execute via socat SYSTEM to process the shell pipeline using the JSON exec form.
# socat runs in blocking mode, staying in the foreground to securely occupy PID 1.
CMD			["socat", "TCP-LISTEN:4243,fork,reuseaddr", "SYSTEM:/usr/bin/fortune | /usr/bin/cowsay"]
