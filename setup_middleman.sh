#!/bin/bash
# Middle Man - Website Caching & Optimizing System - System Setup Script
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
echo "---Middle Man - Website Caching & Optimizing System - System Setup Script---"
echo "---By: Rahim Khoja (rahim.khoja@alumni.ubc.ca)---"
echo

# Requirements: CentOS 7 Base Intsall
#               IPV4 Public IP, (or at least a public IP's Port 80, and 443 routed)
#               Internet Access
#               getpagespeed Repo Access (Fee) or Manually Created RPM's of the same Packages

# Stop on Error
set -eE  # same as: `set -o errexit -o errtrace`

# Dump Vars Function
function dump_vars {
  if ! ${LOGFILE+false};then echo "LOGFILE = ${LOGFILE}";fi
  if ! ${SCRIPTDIR+false};then echo "SCRIPTDIR = ${SCRIPTDIR}";fi
  if ! ${DEBUG+false};then echo "DEBUG = ${DEBUG}";fi
  if ! ${PUBLICIP+false};then echo "PUBLICIP = ${PUBLICIP}";fi
}

# Failure Function
function failure() {
  local lineno=$1
  local msg=$2
  echo "Error at Line: $lineno. - $msg"
  echo ""
  if [[ $DEBUG -eq 1 ]]; then
    dump_vars
  fi
}

# Failure Function Trap
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# Default Variriable Declaration
LOGFILE=/var/log/middleman_setup.log
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEBUG=1
STATUS="Initializing"
TIMESTAMP="$( date +%s )"
#PUBLICIP="$(dig @resolver1.opendns.com ANY myip.opendns.com +short)"
finish="-1"
varnish="0"
nginx="0"
middleman="0"
reinstall="0"
backupconfig="0"
getpagespeed="0"

# Check the bash shell script is being run by root
STATUS="Check - Script Run as Root user"
if [[ $EUID -ne 0 ]];
then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if Varnish is installed.
STATUS="Check - Is Varnish installed"
if [[ -d "/etc/varnish" ]]; then
   varnish="1" 
fi

# Check if NGINX is installed.
STATUS="Check - Is Nginx installed"
if [[ -d "/etc/nginx" ]]; then
   nginx="1" 
fi

# Prompt to Confirm Installation of MiddleMan
STATUS="Prompt - Install Middle Man"
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Do you want to Install MiddleMan [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y"; middleman="1";;
            n | N | no | NO ) answer="n"; middleman="0"; exit 1;;
            *) finish="-1";
                echo -n 'Invalid Response\n';
        esac
    fi
done

# Prompt - NGINX or Varnish are Already Installed, Do you wish to Continue.
STATUS="Prompt - Varnish or Nginx are already installed, Do you want to continue"
if [[ "$nginx" == "1" || "$varnish" == "1" ]]; then
    finish="-1"
    while [ "$finish" = '-1' ]
    do
        finish="1"
        echo
        read -p "MiddleMan Components are already installed. If you continue there is a Risk that settings can be overwritten. Are you sure you want to continue [y/n]? " answer

        if [ "$answer" = '' ];
        then
            answer=""
        else
            case $answer in
                y | Y | yes | YES ) answer="y";;
                n | N | no | NO ) answer="n"; exit 1;;
                *) finish="-1";
                    echo -n 'Invalid Response\n';
            esac
        fi
    done
fi

# Prompt - Backup NGINX or Varnish Settings, Do you wish to Continue.
STATUS="Prompt - Backup Varnish and Nginx settings"
if [[ "$nginx" == "1" || "$varnish" == "1" ]]; then
    finish="-1"
    while [ "$finish" = '-1' ]
    do
        finish="1"
        echo
        read -p "Do you want to Backup existsing NGINX and Varnish configuration files [y/n]? " answer

        if [ "$answer" = '' ];
        then
            answer=""
        else
            case $answer in
                y | Y | yes | YES ) answer="y"; backupconfig='1';;
                n | N | no | NO ) answer="n"; backupconfig='0';;
                *) finish="-1";
                    echo -n 'Invalid Response\n';
            esac
        fi
    done
fi

# Prompt - Use GetPageSpeed Repo or Local RPM's.
STATUS="Prompt - Install and Use GetPageSpeed Repo"
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Do you want to Install & Use the GetPageSpeed Repo? (Highly Suggested - Paid Service) " answer
    
    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y"; getpagespeed='1';;
            n | N | no | NO ) answer="n"; getpagespeed='0';;
            *) finish="-1";
                echo -n 'Invalid Response\n';
        esac
    fi
done

# Create NGINX & Varnish Backups
STATUS="Stopping NGINX & Varnish"
service nginx stop || :
service varnish stop || :
if [[ "$backupconfig" = '1' ]]; then
    STATUS="Backup - Backup NGINX & Varnish Config"
    mv /etc/nginx "/etc/nginx.old.${TIMESTAMP}"
    mv /etc/varnish "/etc/varnish.old.${TIMESTAMP}"
fi

# Install EPEL Repo and System Requirements
yum install -y @Base @Core "@Development Tools" kernel kernel-devel kernel-tools kernel-tools-libs kernel-headers openssh-clients expect make perl patch dkms gcc bzip2 sudo openssl-devel readline-devel zlib-devel net-tools vim wget curl rsync ansible libselinux-python kernel-devel kernel-tools kernel epel-release open-vm-tools http-tools bind-utils

# Update and Upgrade the System
yum update -y && yum -y upgrade

# getPageSpeed Repo Installation
yum -y install https://extras.getpagespeed.com/release-latest.rpm
sed -i 's@repo_gpgcheck=.*@repo_gpgcheck=1@' /etc/yum.repos.d/getpagespeed-extras.repo
yum clean

# GetPageSpeed RPM's (Nginx, Nginx PageSpeed Module, Nginx Brotli Module, Varnish, Varnish Modules, Varnish Geo IP)
yum install -y geoipupdate nginx nginx-module-pagespeed nginx-module-pagespeed-selinux nginx-module-nbr varnish varnish-libs varnish-modules perl-Test-Simple perl-Scalar-List-Utils

# Install CertBot, Varnish Mod, & Cockpit
yum install -y letsencrypt certbot certbot-nginx cockpit vmod-geoip2

# Create Nginx PageSpeed Module Cache Root Directory
mkdir -p /var/cache/pagespeed

# SELINUX - Allow HTTPD Network Connection Access
setsebool -P httpd_can_network_connect 1

# Enable Services
systemctl enable nginx
systemctl enable varnish
systemctl enable cockpit
systemctl enable certbot-renew.service 
systemctl enable certbot-renew.timer

# Setup Firewall-D 
service firewalld start
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=cockpit
firewall-cmd --permanent --add-port=8080/tcp   # May Not Be Needed
firewall-cmd --permanent --add-port=9090/tcp   
firewall-cmd --permanent --add-port=6080/tcp   # May Not Be Needed
firewall-cmd --permanent --add-port=6081/tcp   # May Not Be Needed
firewall-cmd --permanent --add-port=6082/tcp   # May Not Be Needed
firewall-cmd --reload

# Create Nginx Directories
mkdir -p /etc/nginx/defaults || :
mkdir -p /etc/nginx/sites-available || :
mkdir -p /etc/nginx/sites-enabled || :

# Create Varnish Directories 
mkdir -p /etc/varnish/sites-enabled || :
mkdir -p /etc/varnish/sites-available || :

# Create SSL Cert Directories
mkdir -p /etc/ssl/certs || :

# Create Local SSL Cert
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
#openssl dhparam -out /etc/ssl/dhparams.pem 2048

# Backup Original Varnish Files
mv -f /etc/varnish/varnish.params /etc/varnish/varnish.params.orig || :
mv -f /etc/varnish/default.vcl /etc/varnish/default.vcl.orig || :

# Copy Default Varnish Config Files 
cp "${SCRIPTDIR}/etc/varnish/varnish.params" /etc/varnish/varnish.params
cp "${SCRIPTDIR}/etc/varnish/all-vhosts.vcl" /etc/varnish/all-vhosts.vcl
cp "${SCRIPTDIR}/etc/varnish/default.vcl" /etc/varnish/default.vcl
cp "${SCRIPTDIR}/etc/varnish/catch-all.vcl" /etc/varnish/catch-all.vcl

# Backup Original NGINX Files
mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig || :
mv -f /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig || :

# Copy Default NGINX Config Files
cp "${SCRIPTDIR}/etc/nginx/nginx.conf" /etc/nginx/nginx.conf
cp "${SCRIPTDIR}/etc/nginx/sites-enabled/default.conf" /etc/nginx/sites-enabled/default.conf
cp "${SCRIPTDIR}/etc/nginx/sites-available/nginx-confd-default" /etc/nginx/sites-available/nginx-confd-default
cp "${SCRIPTDIR}/etc/nginx/defaults/general.conf" /etc/nginx/defaults/general.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/pagespeed.conf" /etc/nginx/defaults/pagespeed.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/proxy.conf" /etc/nginx/defaults/proxy.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/security.conf" /etc/nginx/defaults/security.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/pagespeed_adv.conf" /etc/nginx/defaults/pagespeed_adv.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/pagespeed.conf" /etc/nginx/defaults/pagespeed.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/ssl.conf" /etc/nginx/defaults/ssl.conf
cp "${SCRIPTDIR}/etc/nginx/defaults/compression.conf" /etc/nginx/defaults/compression.conf

echo 'PATH="/opt/middleman/bin:$PATH";export PATH' >> /etc/profile
