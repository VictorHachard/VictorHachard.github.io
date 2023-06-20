---
layout: note
draft: false
date: 2019-10-10 8:24:00 +0200
author: Victor Hachard
categories: ['System Administration']
---

## Create/delete a folder

```sh
mkdir folder_name
```

```sh
rm folder_name
```

To force the remove

```sh
rm -r folder_name
```

## Create/delete a file

```sh
touch file_name
```

```sh
rm file_name file_name
rm *.pdf
```

## Show the size of a file

```sh
du -h file_name
```

The -h show the size nicely.

## Mount/umount

Show the list of devices:

```sh
fdisk -l
lsblk
```

```sh
mount <device_name> <path>
```

the path use is `/media/usb`

### Umount

Run away from the mounted folder.

```sh
umount path or devices
```

```sh
fuser -m path
```
