---
layout: note
draft: false
date: 2019-10-10 8:24:00 +0200
author: Victor Hachard
---

## Create/delete a folder

```
mkdir folder_name
```

```
rm folder_name
```

To force the remove

```
rm -r folder_name
```

## Create/delete a file

```
touch file_name
```

```
rm file_name file_name
rm *.pdf
```

## Show the size of a file

```
du -h file_name
```

The -h show the size nicely.

## Mount/umount

Show the list of devices:

```
fdisk -l
lsblk
```

```
mount <device_name> <path>
```

the path use is `/media/usb`

### Umount

Run away from the mounted folder.

```
umount path or devices
```

```
fuser -m path
```
