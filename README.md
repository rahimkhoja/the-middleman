# Middle Man - Website Optimization and Caching System
### By: Rahim Khoja (rahim@khoja.ca)
### 

## Description

The Middle Map website optimization and cacheing system acts as a proxy for websites. While being proxied, the site content gets optimizted and cached, which dramatically improves site proformance and PageSpeed score. Getting higher scores on Page Speed Insights ensures websites get better Google search rankings. 

## Components:
--------------

1.  Cockpit
2.  NGINX 
3.  NGINX Brotli Module
4.  NGINX PageSpeed Module
5.	Certbot (https://letsencrypt.org/)
6.  Varnish 4  


## Requirements:
----------------

* Root access to a CentOS 7.* Server with enough space to host the BCH blockchain. (500GB or more)
* Internet Access.  



## Commands 

### Clear the Varnish Cache 

```
varnishadm -T 127.0.0.1:6082 url.purge .
```

Quick Deployment Instrcutions (Work in Progress)
For quick deployment please ensure:

Root access to an updated CentOS 7 server.
As Root Type
yum install -y git
# Need to fill this in

## Useful Links
GetPageSpeed RPM Repository: (Unfortunatly It's a Paid Service)

https://www.getpagespeed.com/redhat

Bind with DLZ Support Documentation:

http://bind-dlz.sourceforge.net/

## Donations
Many Bothans died getting this DNS server to you, honor them by sending me some Bitcoin(BTC). ;)

BTC: 1K4N5msYZHse6Hbxz4oWUjwqPf8wu6ducV

## License
Released under the GNU General Public License v3. (Not sure this is even valid)

http://www.gnu.org/licenses/gpl-3.0.html


/etc/sysconfig/network-scripts/route-ens192



### Quick Deployment Instrcutions (Work in Progress)
-----------

For quick deployment please ensure:

* Root access to an updated CentOS 7 server. 


#### As Root Type
```bash
yum install -y git
cd ~
git clone https://github.com/CanadianRepublican/BitcoinCash-Daemon-Deployment-CentOS7.git BCH-Deploy
cd BCH-Deploy
bash deploy-bch-daemon.sh

```



### Support
-----------

Since I am extremely lazy I am not going to offer any support. Well maybe every once-n-a while. It really depends on my mood. 

That being said, time was spent documenting each command in the scripts. This should allow the scripts to be easily understood and modified if needed. 



