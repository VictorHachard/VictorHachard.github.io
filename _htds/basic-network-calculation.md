---
layout: htd
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

## Find the broadcast of a network

In computer networking, broadcasting refers to transmitting a packet that will be received by every device on the network. In practice, the scope of the broadcast is limited to a broadcast domain.

example: `192.168.0.133/29`

`/29` -> `11111111.11111111.11111111.11111000`
Take the octect where there is the split between `0` and `1` -> `11111000` and complement to 1 -> `00000111`.

`133` --> `10000101`<br/>
`/29` --> `00000111` complemented to 1<br/>
`----------------`<br/>
binary or `10000111`

The broadcast is `10000111`, `192.168.0.135/29`.

## Find the NETID

TODO

## Find the last possible address of a network

TODO
