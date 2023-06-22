---
layout: note
draft: false
date: 2019-06-12 18:08:00 +0200
author: Victor Hachard
categories: ['Networking']
---

## Address classes

| Class |	Network mask | Network addresses | Supports |
| --- | --- | --- | --- |
| A | 255.0.0.0     | 1.0.0.1 to 126.255.255.254    | Supports 16 million hosts on each of 127 networks. |
| B | 255.255.0.0   | 128.1.0.1 to 191.255.255.254  | Supports 65,000 hosts on each of 16,000 networks. |
| C | 255.255.255.0 | 192.0.1.1 to 223.255.254.254  | Supports 254 hosts on each of 2 million networks. |
| D | not defined   | 224.0.0.0 to 239.255.255.255  | Reserved for multicast groups. |
| E | not defined   | 240.0.0.0 to 254.255.255.2545 | Reserved for future use, or research and development purposes. |

## Private IP address

These private IP ranges are as follows:

| Network addresses |
| --- |
| 10.0.0.0 - 10.255.255.255 |
| 172.16.0.0 - 172.31.255.255 |
| 192.168.0.0 - 192.168.255.255 |


## IP Subnet

| Prefix size | Network mask |
| --- | --- |
| /1 | 128.0.0.0 |
| /2 | 192.0.0.0 |
| /3 | 224.0.0.0 |
| /4 | 240.0.0.0 |
| /5 | 248.0.0.0 |
| /6 | 252.0.0.0 |
| /7 | 254.0.0.0 |
