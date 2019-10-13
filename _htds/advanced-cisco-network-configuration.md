---
layout: htd
draft: false
date: 2019-10-13 19:51:00 +0200
author: Victor Hachard
---

## Enable SSH

### Set hostname and domain-name

```
Switch(config)# ip domain-name <domain-name>
```

### Generate the RSA Keys

```
Switch(config)# crypto key generate rsa
 The name for the keys will be: myswitch.thegeekstuff.com
 Choose the size of the key modulus in the range of 360 to 2048 for your
   General Purpose Keys. Choosing a key modulus greater than 512 may take
   a few minutes.

How many bits in the modulus [512]: 1024
 % Generating 1024 bit RSA keys, keys will be non-exportable...[OK]
```

### Setup the Line VTY configurations

```
Switch#line vty 0 4
Switch(config-line)#transport input ssh
Switch(config-line)#login local
Switch(config-line)#no password
Switch(config-line)#exit
```

### Create the username password

```
Switch(config)# username <username> password <password>
```

### Verify SSH access

```
Switch#sh ip ssh
```

### Connect from a device

```
C:\ssh -l <username> <ip_target>
```
