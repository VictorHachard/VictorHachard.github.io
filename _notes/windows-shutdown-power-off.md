---
layout: note
draft: false
date: 2019-06-20 23:28:00 +0200
author: Victor Hachard
categories: ['System Administration', 'Windows']
---

## Commands

1. Start -> Run -> CMD;

2. Type `shutdown` in the open command prompt window;

3. List of various choices that you can do with the command will be listed down, add a `/` ou `-` after `shutdown` to execute a choices. The choices can be combined;

-   s to shutdown your computer
-   r to restart your computer
-   l to log off your computer
-   f allows forcing actions
-   t xx add a time in seconds before shutdown
-   c "text" (optional) to add a small text

![Shutdown CMD]({{site.baseurl}}/res/shutdown-power-off-w10/shutdown-cmd.png)

## Example

To stop your computer in 30 minutes `shutdown /s /f /t 1800`
