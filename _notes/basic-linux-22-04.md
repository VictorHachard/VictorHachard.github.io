---
layout: note
title: Basic linux commands on Ubuntu 22.04
draft: false
date: 2023-06-16 09:37:00 +0200
author: Victor Hachard
categories: ['System Administration']
---

# Sudoers

## Add NOPASSWD

This section modifies the sudoers file to allow specific users to execute commands with sudo privileges without entering a password.

```sh
sudo nano /etc/sudoers.d/ubuntu
```

```sh
ubuntu ALL=(ALL) NOPASSWD:ALL
```

## Add commands

This section adds another entry to the sudoers file, but this time for the deploy user and specifies a list of allowed commands.

```sh
sudo nano /etc/sudoers.d/deploy
```

```sh
deploy ALL=(ALL) NOPASSWD: /bin/mv, /bin/sed, /bin/rm, /bin/chmod, /bin/chown, /home/deploy/scripts/deploy.sh
```

# Create SSH file and folder

This section sets up SSH for the deploy user by creating the necessary file and directory structure. It includes the following commands:

```sh
sudo adduser --disabled-password deploy
mkdir /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
touch /home/deploy/.ssh/authorized_keys
chown deploy:deploy /home/deploy/.ssh/authorized_keys
chmod 600 /home/deploy/.ssh/authorized_keys
```

# Firewall : ufw -> deny incoming, allow outgoing, ssh, http, https

This section configures the Uncomplicated Firewall (UFW) to control incoming and outgoing network traffic.

```sh
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 3222
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

These commands help to secure the system by restricting incoming connections and allowing only specific ports.

# Timezone : Europe/Brussels

This section sets the system's timezone to "Europe/Brussels".

```sh
sudo timedatectl set-timezone Europe/Brussels
```

# unattended-upgrades : 

This section installs and configures the unattended-upgrades package, which automatically applies security updates to the system.

```sh
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

Quit command:

```sh
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -f noninteractive unattended-upgrades
```

The package allows for automatic security updates, reducing the risk of vulnerabilities.

# Update welcome message

This section modifies the MOTD (Message of the Day) to display a custom welcome message.

```sh
sudo nano /etc/update-motd.d/99-custom-welcome
```

```sh
#!/bin/sh

echo "██████  ██████   ██████  ██████  ██    ██  ██████ ████████ ██  ██████  ███    ██ "
echo "██   ██ ██   ██ ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ████   ██ "
echo "██████  ██████  ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ██ ██  ██ "
echo "██      ██   ██ ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ██  ██ ██ "
echo "██      ██   ██  ██████  ██████   ██████   ██████    ██    ██  ██████  ██   ████ "
echo ""
echo ""
```

```sh
#!/bin/sh

echo " ██████ ███████ ██████  ████████ ██ ███████ ██  ██████  █████  ████████ ██  ██████  ███    ██ "
echo "██      ██      ██   ██    ██    ██ ██      ██ ██      ██   ██    ██    ██ ██    ██ ████   ██ "
echo "██      █████   ██████     ██    ██ █████   ██ ██      ███████    ██    ██ ██    ██ ██ ██  ██ "
echo "██      ██      ██   ██    ██    ██ ██      ██ ██      ██   ██    ██    ██ ██    ██ ██  ██ ██ "
echo " ██████ ███████ ██   ██    ██    ██ ██      ██  ██████ ██   ██    ██    ██  ██████  ██   ████ "
echo ""
echo ""
```

```sh
#!/bin/sh

echo "██████  ███████ ██    ██ "
echo "██   ██ ██      ██    ██ "
echo "██   ██ █████   ██    ██ "
echo "██   ██ ██       ██  ██  "
echo "██████  ███████   ████   "
echo ""
echo ""
```  
                         
```sh
sudo chmod +x /etc/update-motd.d/99-custom-welcome
```

These modifications customize the welcome message displayed when logging into the system.