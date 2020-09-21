---
layout: htd
draft: false
date: 2019-10-13 19:51:00 +0200
author: Victor Hachard
---

## Enable SSH

### Set hostname and domain-name

```
Switch(config)#ip domain-name <domain-name>
```

### Generate the RSA Keys

```
Switch(config)#crypto key generate rsa
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
Switch(config-line)#exit
```

### Create the username password

```
Switch(config)#username <username> password <password>
```

```
Switch(config)#username <username> secret <password>
```

### Verify SSH access

```
Switch#sh ip ssh
```

### Connect from a device

```
C:\ssh -l <username> <ip_target>
```

## Set SSH to version 2

```
Switch(config)#ip ssh version 2
```

## Configuring Port Security

[Original article](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst4500/12-2/25ew/configuration/guide/conf/port_sec.html)

```
Switch(config)#interface <interface_id>
Switch(config-if)#switchport mode access
Switch(config-if)#switchport port-security
Switch(config-if)#switchport port-security maximum <value>
Switch(config-if)#switchport port-security violation <restrict | shutdown>
Switch(config-if)#switchport port-security mac-address sticky
Switch(config-if)#end
```

### Add a mac-address

```
Switch(config)#interface <interface_id>
Switch(config-if)#switchport port-security mac-address sticky <mac_address>
Switch(config-if)#end
```

### Show configurations

```
Switch#show port-security address interface <interface_id>
Switch#show port-security address
```

## Vlan

### Create a vlan

```
configure terminal
vlan 10
name name
exit
```

### Config the router

config for the vlan 10

```
interface gigabitEthernet 0/0.10
R1(config-subif)#encapsulation dot1Q 10
R1(config-subif)#ip address 172.17.10.1 255.255.255.0
R1(config-subif)#exit
exit
```
