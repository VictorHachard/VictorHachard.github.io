---
layout: note
title: SSH Key Setup for Fast, Secure Connections on Windows with PuTTY
draft: false
date: 2025-07-08 14:00:00 +0200
author: Victor Hachard
categories: ['System Administration', 'Linux']
---

⚠️ **Warning:** Ensure you have **backup access** (e.g. console or alternative user) before disabling password logins; otherwise you may lock yourself out of the server.

## Purpose

This guide shows how to set up **SSH key–based authentication** from a Windows client using **PuTTYgen** to a Linux server.

## Prerequisites

* **Windows 10/11** with [PuTTY](https://www.putty.org/) (including PuTTYgen)
* **Linux server** with SSH access via password for initial setup

## 1. Generate your SSH keypair with PuTTYgen

1. Launch **PuTTYgen**.
2. Under **Parameters**:

   * **Type of key:** RSA
   * **Number of bits:** 4096
3. Click **Generate**, and move your mouse over the blank area until it completes.
4. **Enter a strong passphrase** (required).
5. **Save your keys**:

   * **Private key (.ppk):** Save as `C:\Users\<You>\.ssh\id_rsa.ppk`
   * **Export OpenSSH key:** PuTTYgen → Conversions → Export OpenSSH key → save as `C:\Users\<You>\.ssh\id_rsa`
   * **Public key:** Copy the “Public key for pasting…” text to a file `C:\Users\<You>\.ssh\id_rsa.pub`

## 2. Install your public key on the Linux server

1. **Copy your public key** to the server:

```bash
# On the server:
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Paste contents of id_rsa.pub into ~/.ssh/authorized_keys:
# Or use a text editor like nano or vim
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAA… your-comment
EOF
chmod 600 ~/.ssh/authorized_keys
```

## 3. Configure Windows OpenSSH client

If you prefer `ssh` over PuTTY:

1. Ensure keys live in `C:\Users\<You>\.ssh\` as `id_rsa` and `id_rsa.pub`.

2. Create or edit `C:\Users\<You>\.ssh\config`:

   ```sshconfig
   Host myserver
     HostName your.server.ip
     User youruser
     IdentityFile ~/.ssh/id_rsa
     IdentitiesOnly yes
   ```

3. Connect with:

   ```powershell
   ssh myserver
   ```
