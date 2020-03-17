#!/bin/sh
# Add New Domain to The Middle Man. This includes CertBot SSL Certificate Setup, Varnish Configureation, and PageSpeed Module.
# By Rahim Khoja (rahim.khoja@alumni.ubc.ca)
# https://www.linkedin.com/in/rahim-khoja-879944139/

echo
echo -e "\033[0;31m░░░░░░░░▀▀▀██████▄▄▄"
echo "░░░░░░▄▄▄▄▄░░█████████▄ "
echo "░░░░░▀▀▀▀█████▌░▀▐▄░▀▐█ "
echo "░░░▀▀█████▄▄░▀██████▄██ "
echo "░░░▀▄▄▄▄▄░░▀▀█▄▀█════█▀"
echo "░░░░░░░░▀▀▀▄░░▀▀███░▀░░░░░░▄▄"
echo "░░░░░▄███▀▀██▄████████▄░▄▀▀▀██▌"
echo "░░░██▀▄▄▄██▀▄███▀▀▀▀████░░░░░▀█▄"
echo "▄▀▀▀▄██▄▀▀▌█████████████░░░░▌▄▄▀"
echo "▌░░░░▐▀████▐███████████▌"
echo "▀▄░░▄▀░░░▀▀██████████▀"
echo "░░▀▀░░░░░░▀▀█████████▀"
echo "░░░░░░░░▄▄██▀██████▀█"
echo "░░░░░░▄██▀░░░░░▀▀▀░░█"
echo "░░░░░▄█░░░░░░░░░░░░░▐▌"
echo "░▄▄▄▄█▌░░░░░░░░░░░░░░▀█▄▄▄▄▀▀▄"
echo -e "▌░░░░░▐░░░░░░░░░░░░░░░░▀▀▄▄▄▀\033[0m"
echo "---The Middle Man - Website Caching & Optimizing System - Add Domain Script---"
echo "---By: Rahim Khoja (rahim.khoja@alumni.ubc.ca)---"
echo

# Default Variables
defaulthn="cookiethief.mech.ubc.ca"
defaultproxy="http://10.10.10.60:8080/"

# Check the bash shell script is being run by root
if [[ $EUID -ne 0 ]];
then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Move to Root Folder
cd /root

# Add new Certbot SSL domain Prompt
finish="-1"
adddomain="0"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Add new SSL domain to NGINX & Certbot [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y"; adddomain="1";;
            n | N | no | NO ) answer="n"; adddomain="0"; exit 1;;
            *) finish="-1";
                echo -n 'Invalid Response\n';
        esac
    fi
done

# Get SSL Domain Name
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Enter Domain to generate a SSL certificate for [$defaulthn]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-$defaulthn}
    echo
    read -p "SSL Domain: $HOSTNAME [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y";;
            n | N | no | NO ) answer="n"; finish="-1"; exit 1;;
            *) finish="-1";
            echo -n 'Invalid Response\n';
        esac
    fi
done

# Get Proxy Site URL
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Enter destination proxy URL for $HOSTNAME SSL domain [$defaultproxy]: " PROXY
    PROXY=${PROXY:-$defaultproxy}
    echo
    read -p "Proxy URL: $PROXY [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y";;
            n | N | no | NO ) answer="n"; finish="-1"; exit 1;;
            *) finish="-1";
            echo -n 'Invalid Response\n';
        esac
    fi
done

# Create SSL Domain NGINX Virtual Host
cp /etc/nginx/conf.d/nginx-confd-default /etc/nginx/conf.d/$HOSTNAME.conf
sed -i "s/<domain>/$HOSTNAME/g" /etc/nginx/conf.d/$HOSTNAME.conf
sed -i "s@<proxy>@$PROXY@g" /etc/nginx/conf.d/$HOSTNAME.conf

# Create PageSpeed Cache Dir
mkdir -p /var/cache/${HOSTNAME}
chmod 700 /var/cache/${HOSTNAME}
chown nginx:nginx /var/cache/${HOSTNAME}


# Create Site Root for SSL Domain
mkdir -p /var/www/${HOSTNAME}/.well-known

# Restart NGINX to enable http for cert generation
service nginx restart

# Create Initial Lets Encrypt Cert for SSL Domain
certbot certonly --webroot -w /var/www/$HOSTNAME -d $HOSTNAME -d www.$HOSTNAME

# Create Local Cert
openssl dhparam -out /etc/letsencrypt/live/$HOSTNAME/dhparams.pem 2048

# Update Selinux and Permissions
chown -R nginx:nginx /var/www
semanage fcontext -a -t httpd_sys_content_t /var/www/$HOSTNAME/*
restorecon -R -v /var/www

# certbot --dry-run renew

# Enable SSL in NGINX Virtual Host File
sed -i '/^#/ s/^#//' /etc/nginx/conf.d/$HOSTNAME.conf

# Restart NGINX to enable SSL
service nginx restart

echo
echo "If there are no errors above, the new SSL certificate is installed correctly."
echo
echo "After SSL redirection is enabled and tested, run the command to test SSL certificate renwals: certbot --dry-run renew"

