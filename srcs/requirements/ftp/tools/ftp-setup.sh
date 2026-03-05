#!/bin/sh

# Add user and set password from the mounted secret file.
# -D : Do not assign a password during creation (handled by chpasswd).
# -h : Set the home directory directly to the WordPress volume.
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
	adduser -D -h /var/www/html $FTP_USER
fi
echo "$FTP_USER:$(cat /run/secrets/ftp_password)" | chpasswd

# Generate SSL certificates for vsftpd if they do not already exist.
# vsftpd is strictly configured to enforce SSL; if these files are missing, the daemon will fatally crash on startup.
mkdir -p /etc/ssl/private /etc/ssl/certs
if [ ! -f /etc/ssl/certs/nginx-selfsigned.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx-selfsigned.key \
		-out /etc/ssl/certs/nginx-selfsigned.crt \
		-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=ftp/CN=eala-lah.42.fr"
fi

# Generate the vsftpd configuration file dynamically.
cat << EOF > /etc/vsftpd/vsftpd.conf
listen=YES
background=NO
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40009
user_sub_token=\$USER
local_root=/var/www/html
allow_writeable_chroot=YES
seccomp_sandbox=NO
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
rsa_cert_file=/etc/ssl/certs/nginx-selfsigned.crt
rsa_private_key_file=/etc/ssl/private/nginx-selfsigned.key
EOF

# Create the empty directory required for secure chroot operations.
mkdir -p /var/run/vsftpd/empty

# Ensure the FTP user owns the web root to allow successful file uploads.
chown -R $FTP_USER:$FTP_USER /var/www/html

echo "FTP server started on port 21 (Passive range: 40000-40009)"

# The 'exec' command is strictly required here. It instructs the Linux kernel to 
# completely destroy this running shell script and replace it with the vsftpd daemon. 
# This promotes vsftpd directly to PID 1, ensuring the service stays natively locked 
# in the foreground without background loops, and properly catches SIGTERM signals.
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
