#!/bin/sh

# Add user and set password from secret
# -D: don't assign a password yet
# -h: set the home directory to the wordpress volume
adduser -D -h /var/www/html $FTP_USER
echo "$FTP_USER:$(cat /run/secrets/ftp_password)" | chpasswd

# Configure vsftpd
cat << EOF > /etc/vsftpd/vsftpd.conf
listen=YES
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
EOF

# Create empty dir for secure chroot
mkdir -p /var/run/vsftpd/empty

# Ensure the FTP user owns the web root to allow uploads
chown -R $FTP_USER:$FTP_USER /var/www/html

echo "FTP started on port 21 (Passive range 40000-40009)"
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
