#!/bin/bash
# Middle Man - Web Site Caching & Optomizing System
# By Rahim Khoja (rahim.khoja@alumni.ubc.ca)

# Requirements: CentOS 7 Base Intsall
#               Internet Access
#               Static Public IP
#               getpagespeed Repo Access (Fee) or Manually Created RPM's of the same Packages

set -eE  # same as: `set -o errexit -o errtrace`
# Dump Vars Function
function dump_vars {
  if ! ${LOGFILE+false};then echo "LOGFILE = ${LOGFILE}";fi
  if ! ${SCRIPTDIR+false};then echo "SCRIPTDIR = ${SCRIPTDIR}";fi
    if ! ${DEBUG+false};then echo "DEBUG = ${DEBUG}";fi
}

# Failure Function
failure() {
  local lineno=$1
  local msg=$2
  echo "Error at Line: $lineno. - $msg"
  echo ""
  if [[ $DEBUG -eq 1 ]]; then
    dump_vars
  fi
}

# Default Variriable Declaration
LOGFILE=/var/log/logfilename.log
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEBUG=1

Fail On This

# getPageSpeed Repo Installation
yum -y install https://extras.getpagespeed.com/release-latest.rpm
sed -i 's@repo_gpgcheck=.*@repo_gpgcheck=1@' /etc/yum.repos.d/getpagespeed-extras.repo
yum clean

# Install EPEL Repo and System Requirements
yum install -y @Base @Core @Development Tools kernel kernel-devel kernel-tools kernel-tools-libs kernel-headers openssh-clients expect make perl patch dkms gcc bzip2 sudo openssl-devel readline-devel zlib-devel net-tools vim wget curl rsync ansible libselinux-python kernel-devel kernel-tools kernel epel-release open-vm-tools http-tools

# Update and Upgrade the System
yum update -y && yum -y upgrade

# Install CertBot, Nginx, Nginx PageSpeed Module, Nginx Brotli Module, Varnish, Varnish Modules, Varnish Geo IP, & Cockpit
yum install -y letsencrypt nginx certbot certbot-nginx cockpit nginx-module-pagespeed nginx-module-nbr varnish varnish-modules vmod-geoip2

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


yum -y install https://extras.getpagespeed.com/release-latest.rpm

sed -i 's@repo_gpgcheck=.*@repo_gpgcheck=1@' /etc/yum.repos.d/getpagespeed-extras.repo

yum clean

yum install -y letsencrypt nginx certbot certbot-nginx cockpit nginx-module-pagespeed nginx-module-nbr varnish varnish-modules vmod-geoip2


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

/etc/varnish/varnish.params
/etc/varnish/all-vhosts.vcl
/etc/varnish/default.vcl
/etc/varnish/catch-all.vcl


/etc/nginx/nginx.conf
/etc/nginx/conf.d/default.conf

vi /etc/nginx/conf.d/nginx-confd-default
vi /etc/nginx/defaults/general.conf
vi /etc/nginx/defaults/pagespeed.conf
vi /etc/nginx/defaults/proxy.conf
vi /etc/nginx/defaults/security.conf
vi /etc/nginx/defaults/pagespeed_adv.conf
vi /etc/nginx/defaults/pagespeed.conf
vi /etc/nginx/defaults/ssl.conf
vi /etc/nginx/defaults/compression.conf
