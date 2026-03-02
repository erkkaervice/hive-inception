FROM	alpine:3.19

RUN	apk update && apk add --no-cache vsftpd

# Copy and prepare the startup script
COPY	tools/script.sh /usr/local/bin/ftp-setup.sh
RUN	chmod +x /usr/local/bin/ftp-setup.sh

# FTP Command Port
EXPOSE	21

# FTP Passive Mode Ports
EXPOSE	40000-40009

# Run the setup script
ENTRYPOINT	["sh", "/usr/local/bin/ftp-setup.sh"]
