---
layout: note
draft: false
date: 2020-11-27 10:54:00 +0200
author: Victor Hachard
categories: ['System Administration']
---

## Commands

```sh
sudo nextcloud.occ files:scan -- victor
```

## Jail cli Commands

```sh
iocage list
iocage console jail_nextcloud
```

```sh
pkg install nano
```

```sh
cd /usr/local/www/nextcloud
su -m www -c /bin/sh
php ./occ maintenance:mode --off

php ./occ config:system:set trusted_domains 0 --value=192.168.0.12
php ./occ config:system:set trusted_domains 1 --value=85.201.97.128
php ./occ config:system:set trusted_domains 2 --value=cloud.victorhachard.fr
```

```sh
iocage console nextcloud

/mnt/DatasPool/iocage/jails/nextcloud/root
/mnt/DatasPool/iocage/jails/nextcloud/root/usr/local/www/nextcloud/data
/usr/local/www/nextcloud/data

Database Name: nextcloud
Database User: dbadmin
Database Password: Gdllh9nKKT6tMcG8
Nextcloud Admin User: ncadmin
Nextcloud Admin Password: PqU7hX7AU0t0OSjc

----------------------

cp -r data data2
rm -r data

-------------

cp -r data2 data
rm -r data2
chmod 770 data
chown www:wheel data

------

#Edit nginx.conf to enforce HTTPS (change nextcloud.mindynguyen.org to your)
# You can still able to access https://localhost if you do not have DNS at home
vi /usr/local/etc/nginx/nginx.conf
server {
    listen      80;
    #listen [::]:80;
    server_name cloud.victorhachard.fr;
    return      301 https://$server_name$request_uri;
}

#Edit nextcloud.conf to enforce HTTPS (change nextcloud.mindynguyen.org to your)
vi /usr/local/etc/nginx/conf.d/nextcloud.conf

server {
  listen              443 ssl http2;
  #listen              [::]:443 ssl http2;
  server_name         cloud.victorhachard.fr;
  ssl_certificate     /usr/local/etc/letsencrypt/live/cloud.victorhachard.fr/fullchain.pem;
  ssl_certificate_key /usr/local/etc/letsencrypt/live/cloud.victorhachard.fr/privkey.pem;
  add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";

#Add trusted domains (Skip this step if you do not have DNS)
vi /usr/local/www/nextcloud/config/config.php
2 => '109.89.13.57',
3 => 'cloud.victorhachard.fr',

#Set Let's Encrypt
echo "FreeBSD: { enabled: yes }" > /usr/local/etc/pkg/repos/FreeBSD.conf

pkg install py37-certbot
certbot certonly --webroot

fqdn: cloud.victorhachard.fr
/usr/local/www/nextcloud

echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | tee -a /etc/crontab > /dev/null
```

```sh
#NextCloud
iocage console nextcloud

pkg update -f

portsnap fetch extract

#Install Nano Text Editor
cd /usr/ports/editors/nano/ && make install clean BATCH=yes

#Make folder and generate OpenSSL Cert/Key
mkdir -p /usr/local/etc/ssl/nginx

cd /usr/local/etc/ssl/nginx

#Generte Self-Signed Certificate (change nextcloud.mindynguyen.org to your)
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout cloud.victorhachard.fr.key -out cloud.victorhachard.fr.crt

chmod 400 /usr/local/etc/ssl/nginx/cloud.victorhachard.fr.key
ls -l /usr/local/etc/ssl/nginx

#Edit nginx.conf to enforce HTTPS (change nextcloud.mindynguyen.org to your)
# You can still able to access https://localhost if you do not have DNS at home
nano /usr/local/etc/nginx/nginx.conf
server {
    listen      80;
    #listen [::]:80;
    server_name cloud.victorhachard.fr;
    return      301 https://$server_name$request_uri;
}

#Edit nextcloud.conf to enforce HTTPS (change nextcloud.mindynguyen.org to your)
nano /usr/local/etc/nginx/conf.d/nextcloud.conf

server {
  listen              443 ssl http2;
  #listen              [::]:443 ssl http2;
  server_name         cloud.victorhachard.fr;
  ssl_certificate     /usr/local/etc/letsencrypt/live/cloud.victorhachard.fr/fullchain.pem;
  ssl_certificate_key /usr/local/etc/letsencrypt/live/cloud.victorhachard.fr/privkey.pem;
  add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";

Add trusted domains (Skip this step if you do not have DNS)
nano /usr/local/www/nextcloud/config/config.php
Control W search for trusted domains and add your FQDM in there
1 => 'cloud.victorhachard.fr',

Fix Opcache
nano /usr/local/etc/php.ini
remove the ; to Enable and set the values to the recommended values on NextCloud Overview tab.
Restart nextcloud plugin for changes to take effect.
```
