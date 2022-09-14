---
layout: note
draft: false
date: 2019-06-11 17:37:00 +0200
author: Victor Hachard
---

**This page is not finish**

## Find the number of subnets for a network

Subnetting is the process of diving a network into small networks and is a common task on IPV4 networks.

example: `192.168.0.25/29`

`/29` -> `11111111.11111111.11111111.11111000`

Take the octect where there is the split between `0` and `1` -> `11111000`. Count the number of bits (`1`), int the example there is 5 bits that are used to identify the subnet. To find the total number of subnets available simply raise 2 to the power of `5` like that: <img src="https://tex.s2cms.ru/svg/2%5E5" alt="2^5" /> = 32. The number of subnet is 32.

## Find the number of host addresses for a network

The total number of IPv4 host addresses for a network is 2 to the power of the number of host bits, which is 32 minus the number of network bits.

example: `192.168.0.25/29`

Do `32` minus the mask of the network the whole squared minus `2` like that: <img src="https://tex.s2cms.ru/svg/((32-29)%5E2)-2" alt="((32-29)^2)-2" /> = 6. The number of hosts is 6.

## Find the broadcast address of a network

In computer networking, broadcasting refers to transmitting a packet that will be received by every device on the network. In practice, the scope of the broadcast is limited to a broadcast domain.

example: `192.168.0.133/29`

`/29` -> `11111111.11111111.11111111.11111000`
Take the octect where there is the split between `0` and `1` -> `11111000` and complement to 1 -> `00000111`.

`133` --> `10000101`<br/>
`/29` --> `00000111` complemented to 1<br/>
`----------------`<br/>
binary or `10000111`

The broadcast is `10000111`, `192.168.0.135/29`.

## Find network address / NETID

A network address is an identifier for a node or host on a telecommunications network.

example: `173.115.163.86/20`

`163` --> `10100011`<br/>
`163` --> `1010|0011`cutting<br/>

Take the left part `1010` -> `160`<br/>

-   The network address is `173.115.160.0/20`.
-   The first network address is `173.115.160.1/20`.

## Find the last possible address of a network

example: `173.115.163.86/20`
network address: `173.115.160.0/20`

`1010|1111.11111111` remplace the right paty by one<br/>
`1010|1111.11111111` -> `175.255`<br/>

-   The broadcast address is `173.115.175.255/20`.
-   The last possible address is `173.115.175.254/20`
