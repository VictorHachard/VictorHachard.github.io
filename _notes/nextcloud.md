---
layout: note
draft: false
date: 2020-11-27 10:54:00 +0200
author: Victor Hachard
---

## Commands

```
sudo nextcloud.occ files:scan -- victor
```


## Jail cli Commands

```
iocage list
iocage console jail_nextcloud
```

```
pkg install nano
```

```
cd /usr/local/www/nextcloud
su -m www -c /bin/sh
php ./occ maintenance:mode --off

php ./occ config:system:set trusted_domains 0 --value=192.168.0.12
php ./occ config:system:set trusted_domains 1 --value=85.201.97.128
php ./occ config:system:set trusted_domains 2 --value=cloud.victorhachard.fr
```
