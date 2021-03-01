---
layout: note
draft: false
date: 2020-10-09 10:05:00 +0200
author: Victor Hachard
---

## Commands

```
top -m io
zfs iostat JojoPool 1
zpool list
```

## Nextcloud

```
sudo nextcloud.occ config:system:set trusted_domains 1 --value=109.89.13.57
sudo nextcloud.occ config:system:set trusted_domains 2 --value=cloud.victorhachard.fr
```

```
#add nfs share
#In freenas do a dataset and set permission: root, wheel; only owner and group need right.
#Share this dataset un UNIX and set mapall User: root, mapall Group: wheel
#Server side add this to fstab
#vi /etc/fstab
#sudo mount 192.168.0.10:/mnt/DatasPool/NextCloud /media/data
echo "192.168.0.10:/mnt/DatasPool/NextCloud /media/data nfs defaults    0 0" >> /etc/fstab
```

```
#Change the location od the datadirectory to /media/data
vi /var/snap/nextcloud/current/nextcloud/config/config.php
```

```
sudo ufw allow 80,443/tcp
sudo nextcloud.enable-https lets-encrypt
```

```
sudo apt-get install unrar
sudo apt-get install p7zip p7zip-full
sudo apt-get install ffmpeg
```

```
sudo nextcloud.occ files:scan --path=/victor/files
mv /mnt/DatasPool/Datas/Clouded /mnt/DatasPool/NextCloud/data/victor/files
chown -R root:wheel Backup
//chmod 755 Backup
```

## Transmission plugin

### Mount points

```
Source: /mnt/volum3/download/transmission
Destination: /mnt/volum3/iocage/jails/transmission/root/usr/local/etc/transmission/home/Downloads
```

https://flemmingss.com/how-to-install-and-configure-transmission-plugin-in-freenas-11-3/
