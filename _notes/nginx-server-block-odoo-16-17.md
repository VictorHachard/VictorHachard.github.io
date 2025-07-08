---
layout: note
title: Nginx Server Block for Odoo 16 and 17
draft: false
active: false
date: 2025-02-06 14:00:00 +0200
author: Victor Hachard
categories: ['Odoo', 'System Administration']
---

⚠️ **Warning:** The only differences between the Odoo 16/17 configuration and the Odoo 11/15 setup are:

- Renaming the `/longpolling` location to `/websocket`
- Enabling static-asset caching in the proxy manager.

## Purpose

This guide provides a complete Nginx configuration for Odoo 11 and 15, including SSL setup, HTTP to HTTPS redirection, and long-polling support. It is designed to be used with Nginx Proxy Manager or directly in an Nginx configuration file.

## References

- [Odoo 16 Deployment Guide](https://www.odoo.com/documentation/16.0/administration/on_premise/deploy.html#https)
- [Odoo 17 Deployment Guide](https://www.odoo.com/documentation/17.0/administration/on_premise/deploy.html#https)

## Odoo Configuration

Ensure your Odoo configuration includes the following settings to enable proxy mode:

```ini
proxy_mode = True
```

## Nginx Configuration file

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name odoo.example.com;
    return 301 https://$host$request_uri;
}

# Redirect www to non-www
server {
    listen 80;
    server_name www.odoo.example.com;
    return 301 https://odoo.example.com$request_uri;
}

# Odoo server block
server {
    listen 443 ssl http2;
    server_name odoo.example.com;

    # SSL configuration
    ssl on;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate /etc/letsencrypt/live/odoo.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/odoo.example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot

    # allow uploads up to 6 GB for large attachments
    client_max_body_size 6G;

    # extend proxy timeouts to 30 minutes for long-running Odoo operations
    proxy_read_timeout  1800s;   # waits this long for a response from the proxied server
    proxy_connect_timeout 1800s; # waits this long to establish connection with upstream
    proxy_send_timeout 1800s;    # waits this long to send a request to the proxied server

    # enable gzip compression for static files
    gzip on;
    gzip_types text/css application/javascript image/svg+xml image/x-icon image/png image/jpeg;

    # Logging
    access_log /var/log/nginx/odoo_access.log;
    error_log /var/log/nginx/odoo_error.log;

    # Odoo proxy settings
    location / {
        proxy_pass http://internal-odoo-server:8069;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_cookie_flags session_id samesite=lax secure;
    }

    location /websocket {
        proxy_pass http://internal-odoo-server:8072;
        set $connection_upgrade 'close';
        if ($http_upgrade != "") {
            set $connection_upgrade 'upgrade';
        }

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_cookie_flags session_id samesite=lax secure;
    }

    # Block indexers from crawling the site
    location = /robots.txt {
        return 200 "User-agent: *\nDisallow: /\n";
    }

}
```

## Nginx Proxy Manager Configuration

### Details

- **Domain Names**: odoo.example.com
- **Scheme**: `http`
- **Forward Hostname / IP**: `internal-odoo-server` (or the internal IP address of your Odoo server)
- **Forward Port**: `8069` (or the port your Odoo server is running on)
- **Block Common Exploits**: `ON`
- **Cache Assets**: `ON`
- **Websockets Support**: `OFF`

### Custom Location

#### Websocket Support

- **Location**: `/longpolling`
- **Scheme**: `http`
- **Forward Hostname / IP**: `internal-odoo-server` (or the internal IP address of your Odoo server)
- **Forward Port**: `8072` (or the port your Odoo server is running on)
- **Nginx Configuration**: Add the following lines to the advanced tab:

```nginx
set $connection_upgrade 'close';
if ($http_upgrade != "") {
    set $connection_upgrade 'upgrade';
}

proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
proxy_set_header X-Forwarded-Host $http_host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Real-IP $remote_addr;

proxy_cookie_flags session_id samesite=lax secure;
```

#### Main Location

- **Location**: `/`
- **Scheme**: `http`
- **Forward Hostname / IP**: `internal-odoo-server` (or the internal IP address of your Odoo server)
- **Forward Port**: `8069` (or the port your Odoo server is running on)
- **Nginx Configuration**: Add the following lines to the advanced tab:

```nginx
proxy_set_header X-Forwarded-Host $http_host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Real-IP $remote_addr;
proxy_redirect off;

proxy_cookie_flags session_id samesite=lax secure;
```

### SSL Certificate

- **Force SSL**: `ON`
- **HTTP/2 Support**: `ON`
- **HSTS Enabled**: `ON`
- **HSTS Subdomains**: `ON`

### Advanced

- **Custom Nginx Configuration**: Add the following lines to the advanced tab:

```nginx
# Block indexers from crawling the site
location = /robots.txt {
    return 200 "User-agent: *\nDisallow: /\n";
}

# allow uploads up to 6 GB for large attachments
client_max_body_size 6G;

# extend proxy timeouts to 30 minutes for long-running Odoo operations
proxy_read_timeout  1800s;   # waits this long for a response from the proxied server
proxy_connect_timeout 1800s; # waits this long to establish connection with upstream
proxy_send_timeout 1800s;    # waits this long to send a request to the proxied server
```