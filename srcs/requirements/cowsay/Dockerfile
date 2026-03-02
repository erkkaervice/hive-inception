FROM alpine:3.19

# Install socat and fortune from standard repos, and cowsay from the testing repo
RUN apk update && apk add --no-cache socat fortune && \
	apk add --no-cache cowsay --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

EXPOSE 4242

# Execute via socat SYSTEM to process the shell pipeline
CMD ["socat", "TCP-LISTEN:4242,fork,reuseaddr", "SYSTEM:/usr/bin/fortune | /usr/bin/cowsay"]
