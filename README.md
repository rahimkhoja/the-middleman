# Middle Man - Website Optimization and Caching System
### By: Rahim Khoja (rahim@khoja.ca)

## Description

The Middle Map website optimization and caching system acts as a proxy for websites. While being proxies, the site content gets optimized and cached, which dramatically improves site performance and PageSpeed score. Getting higher scores on Page Speed Insights ensures websites get better Google search rankings. 


## Components:

1.  Cockpit
2.  NGINX 
3.  NGINX Brotli Module
4.  NGINX PageSpeed Module
5.	Certbot (https://letsencrypt.org/)
6.  Varnish 4  


## Requirements:

1.  Basic CentOS 7.x Server with Root access. 
2.  A Public IP assigned or routed to the server.
3.  Internet Access (this should be a given)


## Deployment Instructions:

#### As Root Type
```
yum install -y git
cd ~
git clone https://github.com/rahimkhoja/middleman.git MiddleMan
cd MiddleMan
bash setup_middleman.sh

```

## Support

Since I am extremely lazy I am not going to offer any support. Well maybe every once-n-a while. It really depends on my mood. 

That being said, time was spent documenting each command in the scripts. This should allow the scripts to be easily understood and modified if needed. 


## Useful Information

### Commands 

#### Clear the Varnish Cache 

```
varnishadm -T 127.0.0.1:6082 url.purge .
```

#### Reload NGINX

```
service nginx reload
```

#### Test if Varnish is correctly configured for a particular Domain.

Make sure you update 'example.com' with your domain name.
```
curl --verbose --header 'Host: example.com' 'http://127.0.0.1:6081'

```

#### Add Static Route To Interface

Make sure you update 'ens192' with your systems Network Device and the Route you wish to add.  
```
echo '104.18.48.227/32 via 172.19.254.1 dev ens192' >>
/etc/sysconfig/network-scripts/route-ens192
```

### Links
GetPageSpeed RPM Repository: (Unfortunately It's a Paid Service)

https://www.getpagespeed.com/redhat

Varnish 4.x Website:

https://varnish-cache.org/docs/4.1/

Nixing Website:

https://nginx.org/en/docs/

Passed Module Website:

https://www.modpagespeed.com/doc/configuration

Brotli:

https://docs.nginx.com/nginx/admin-guide/dynamic-modules/brotli/


## Donations
Many Bothans died getting this optimization and caching system to you, honor them by sending me some Bitcoin(BTC). ;)

BTC: 1K4N5msYZHse6Hbxz4oWUjwqPf8wu6ducV


## License
Released under the GNU General Public License v3. 

http://www.gnu.org/licenses/gpl-3.0.html
