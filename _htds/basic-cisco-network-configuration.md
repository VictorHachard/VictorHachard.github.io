---
layout: htd
draft: false
date: 2019-06-14 15:47:00 +0200
author: Victor Hachard
---

## Basic commands

### Enter privileged mode

```
Router>enable or en
Router#
```

### Enter global configuration mode

```
Enter configuration commands, one per line. End with CNTL/Z.
Router#configure terminal or conf t
Router(config)#
```

### Exit the current configuration mode and return to the previous mode

```
Router(config)#exit
Router#
```

### See the list of available commands in the current mode

```
Router(config)#?
```

This will display all available commands. If there is a -More-, you can either do it to display the next line or make a space to display the next page. To quit the display, press the Q key or CTRL + C combination

### Save

```
Routeur#copy running-config startup-config or copy run start
Destination filename ?
Building configuration...
```

```
Routeur#wr
Building configuration...
```

```
Routeur#reload
Proceed with reload? [confirm]
```

## Secure a router/switch

### Set the name of the router and the domain name

```
Router(config)#hostname <name>
Router(config)#ip domain-name <domain_name>
```

```
Router(config)#no hostname
Router(config)#no ip domain-name
Router(config)#
```

### Prevent unwanted DNS lookups

```
Router(config)# no ip domain-lookup
```

### Set a console password

```
Router(config)#line console 0
Router(config-line)#password <password>
Router(config-line)#login
Router(config-line)#exit
```

### Set a telnet password

```
Router(config)#line vty 0 4
Router(config-line)#password <remote_access_password>
Router(config-line)#login
Router(config-line)#exit
```

### Set a preferred mode password

```
Router(config)# enable secret <password>
```

### Create a banner

```
Router(config)#banner motd #
```

```
Router(config)#no banner motd
```

### Encrypt passwords

```
Router(config)#service password-encryption
```

## Add vlan to a switch

```
Switch(config)#vlan <number>
Switch(config-if)#name <name>
```

```
Switch(config)#no vlan <number>
```

```
Switch(config)#interface <interface>
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan <number>
Switch(config-if)#exit
```

## Switch static mapping

```
Switch(config)#mac-address-table static <mac_address> vlan <vlan> interface <output_interface>
```

## Add a default gateway

```
Switch(config)#ip default-gateway <ip_address>
```

## View and test

```
Router#ping <ip_address>
```

```
Switch#show interfaces
```

```
Router#show ip route or sh ip rou
```

```
Switch#show ip interface brief or sh ip int br
```

```
Switch#show ipv6 interface brief or sh ipv6 int br
```

## IP addressing on router

### IPv4

#### Add an ip address

- Interface: Fa0/0
- IP adress: 192.168.100.1
- Subnet Mask: 255.255.255.0

```
Router(config)#interface fastEthernet 0/0
Router(config-if)#ip address 192.168.100.1 255.255.255.0
Router(config-if)#description <text>
Router(config-if)#no shutdown or no sh
```

```
Router(config)#int fa0/0
Router(config-if)#no shutdown or no sh
```

####  Remove an ip address

```
Router(config)#interface fastEthernet 0/0
Router(config-if)#no ip address
```

```
Router(config)#int fa0/0
Router(config-if)#shutdown or sh
```

### IPv6

ipv6 routing is disabled on your routers which prevents ipv6 communication between different pc. You must activate it with this command:

```
Router(config)#ipv6 unicast-routing
```

#### IPv6 addressing with link-local

```
Router(config)#int fa0/0
Router(config-if)#ipv6 address FE80::1 link-local
Router(config-if)#no shutdown or no sh
```

#### Add IPv6 addressing

```
Router(config)#int fa0/0
Router(config-if)#ipv6 address 2001:....:1/64
Router(config-if)#no shutdown or no sh
```

## Route

### IPv4 Route static

#### Add a route

```
Router(config)#ip route <network_address> <subnet_mask> <output_interface>
```

```
Router(config)#ip route <network_address> <subnet_mask> <ip_address_of_the_next_device>
```

```
Router(config)#ip route <network_address> <subnet_mask> <output_interface> <ip_address of_the_next_device>
```

#### Remove a route

```
Router(config)#no ip route <network_address> <subnet_mask> <output_interface>
```

```
Router(config)#no ip route <network_address> <subnet_mask> <ip_address_of_the_next_device>
```

### Default IPv4 static route

```
Router(config)#ip route 0.0.0.0 0.0.0.0 <output_interface>
```

### IPv6 Route static

- Subnet or information must go: 2001:6A8:3540:A::1/64
- Ipv6 address of the interface of the next device: 2001:6A8:3540:D::1

```
Router(config)#ipv6 route 2001:6A8:3540:A::1/64 2001:6A8:3540:D::1
```

### Default IPv6 static route

```
Router(config)#ipv6 route ::/0 <output_interface>
```

## Save to a TFTP server
```
!!!! Copy to a server
copy running-config tftp
!!!! Copy from a server
copy tftp running-config
```
