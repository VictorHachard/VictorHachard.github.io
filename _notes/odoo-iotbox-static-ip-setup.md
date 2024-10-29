---
layout: note
title: Odoo IoT Box Static IP Setup
draft: false
date: 2024-10-29 16:30:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

1. **Access the IoT Box Webpage:**
   - Go to the IoT Box webpage and enable remote debugging.
   - Generate a password for secure access.

2. **Connect to the IoT Box via SSH:**
   - Open an SSH connection to the IoT Box using:
     ```
     ssh pi@<ip_address>
     ```
   - Use the password generated in the previous step.

3. **Enable Write Mode on the Filesystem:**
   - By default, the Odoo filesystem is mounted in read-only mode. To make changes, switch to write mode using the following commands:
     ```bash
     sudo mount -o rw,remount / && sudo mount -o remount,rw /root_bypass_ramdisks
     ```

4. **Edit Network Configuration for Persistent Settings:**
   - Open the network configuration file for editing:
     ```bash
     nano /root_bypass_ramdisks/etc/dhcpcd.conf
     ```
   - Add the necessary network settings to the file. For example:
     ```plaintext
     interface eth0
     static ip_address=192.168.1.100/24  # Replace with the desired IP
     static routers=192.168.1.1          # Replace with your gateway
     static domain_name_servers=8.8.8.8  # You can add more DNS if needed
     ```
   - **Note:** Ensure you’re editing the file in `/root_bypass_ramdisks/etc/` to make the changes permanent.

5. **Reboot the IoT Box:**
   - Use the reboot option in the IoT Box webpage interface to apply the changes.
