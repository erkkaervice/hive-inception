FROM		alpine:3.22

# Install vsftpd
RUN			apk update && apk add --no-cache vsftpd openssl

# Copy and prepare the startup script
COPY		tools/ftp-setup.sh /usr/local/bin/ftp-setup.sh
RUN			chmod +x /usr/local/bin/ftp-setup.sh

# Expose FTP Command and Passive Mode Ports
EXPOSE		21
EXPOSE		40000-40009

# Run the setup script via the JSON exec form.
# The script must end with 'exec vsftpd' to destroy the shell process
# and promote the FTP daemon directly to PID 1.
ENTRYPOINT	["sh", "/usr/local/bin/ftp-setup.sh"]
