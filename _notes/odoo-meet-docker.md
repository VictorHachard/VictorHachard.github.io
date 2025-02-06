---
layout: note
title: Odoo Deployment with Docker
draft: false
date: 2024-11-14 14:44:00 +0200
author: Victor Hachard
categories: ['Docker', 'Odoo', 'System Administration']
---

⚠️ **Warning:** tested on Odoo 16.0 with Ubuntu 24.04.1 LTS in early 2025.

## Overview  

Deploy Odoo 16 with Docker on Ubuntu 24.04.1 LTS (early 2025). Covers private registry, reverse proxy, logging, custom image creation, container execution, PostgreSQL, and Seq integration.

### Required Skills  

- Containerization & Orchestration:
  - Docker (images, containers, volumes, networks)  
  - Docker Compose (`docker-compose.yml`)  
- Image Management:
  - Private Docker Registry  
- Infrastructure & Administration:
  - Portainer (Docker management)  
  - Linux (filesystem, permissions, users, process control)  
- Reverse Proxy & Security:
  - Nginx Proxy Manager (GUI)  
  - Nginx (reverse proxy)  
- Database:
  - PostgreSQL (SQL, users, backups, restores)  
- Development & Logging:
  - Odoo (architecture, container execution)  
  - Seq (centralized logging)  
  - Bash (automation, log management)  
- CI/CD & Automation:
  - Git (version control)  
  - GitHub Actions & DevOps (CI/CD pipelines, webhooks)  
- Networking:
  - DNS & Internal Routing (Docker service communication)  

## Server Setup

### Prerequisites

- Updating and upgrading the system
- Setting the timezone (Brussel)
- Installing and configuring ufw (allow SSH, HTTP, HTTPS)
- Installing and activate unattended upgrades (activate: Distro-Update, Remove-Unused-Kernel-Packages, Remove-New-Unused-Dependencies, Remove-Unused-Dependencies, Automatic-Reboot, Automatic-Reboot-Time)

📌 **TL;DR:**

```bash
# Update and upgrade
sudo apt update && sudo apt upgrade -y

# Set timezone
sudo timedatectl set-timezone Europe/Brussels

# Install and configure ufw
sudo apt install ufw -y && sudo ufw allow OpenSSH && sudo ufw allow http && sudo ufw allow https && sudo ufw enable

# Install and activate unattended upgrades
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -f noninteractive unattended-upgrades
```

### Install Docker

Install Docker using Snap or APT.

#### Install Docker with Snap

Docker can be installed using Snap during the Ubuntu setup or manually afterward.

⚠️ **Warning:** To avoid unexpected interruptions due to automatic updates, configure Snap to control Docker updates.

Set a specific update window to limit when Docker updates can occur (e.g., every Monday between 03:15 and 03:30 AM):

```bash
sudo snap refresh --time
sudo snap set system refresh.timer=mon,3:15-3:30
```

This ensures that Docker updates only during the defined time, reducing the risk of unexpected downtime.

#### Install Docker with APT

Refer to the official [Docker documentation](https://docs.docker.com/engine/install/ubuntu/) for the latest installation instructions.

### Install Portainer

Refer to the official [Portainer documentation](https://docs.portainer.io/start/install-ce/server/docker/linux) for the latest installation instructions.

📌 **TL;DR:**

```bash
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.4
```

After running the command, access the UI at `http://<your_server_ip>:9443`.

### Install Docker Registry

Install a private Docker registry to store and manage custom images.

```yaml
services:
  registry:
    image: registry:2
    container_name: registry
    restart: unless-stopped
    ports:
      # Format: <host-port>:<container-port>
      - "5000:5000"
    environment:
      - REGISTRY_AUTH=htpasswd
      - REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm
      - REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
      - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry
      - REGISTRY_STORAGE_DELETE_ENABLED=true
    volumes:
      - registry_data:/var/lib/registry
      - registry_auth:/auth
    
volumes:
  registry_data:
  registry_auth:
```

#### Link the Registry to Portainer

Refer to the official [Portainer documentation](https://docs.portainer.io/admin/registries/add/custom#:~:text=From%20the%20menu%20select%20Registries,enter%20the%20username%20and%20password.) for detailed instructions.

📌 **TL;DR:** Navigate to the Portainer dashboard and add a new registry endpoint with the following details:

- Name: `Odoo Registry`
- Endpoint URL: `https://registry.example.com`
- Authentication: `Yes`
- Username: `USERNAME`
- Password: `PASSWORD`

#### Create a User for the Registry

To secure the registry, create a new user by generating a bcrypt-encrypted password and storing it in the `htpasswd` file:

```bash
docker run --entrypoint htpasswd httpd:2 -Bbn USERNAME PASSWORD > PATH_TOVOLUME/htpasswd
```

Alternatively, manually add a new user to the `htpasswd` file:

```bash
echo 'USERNAME:BCRYPT_PASSWORD' >> /auth/htpasswd
```

#### List Registry Images & Tags

```bash
curl -X GET -u USERNAME:PASSWORD https://registry.example.com/v2/_catalog
curl -u USERNAME:PASSWORD https://registry.example.com/v2/IMAGE_NAME/tags/list
```

### Install Nginx Proxy Manager

Refer to the official [Nginx Proxy Manager documentation](https://nginxproxymanager.com/setup/) for the latest installation instructions.

📌 **TL;DR:**

```yaml
services:
  app:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '80:80'   # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81'   # Admin Web Port
    environment:
      DISABLE_IPV6: 'true'
    volumes:
      - data_volume:/data
      - letsencrypt_volume:/etc/letsencrypt

volumes:
  data_volume:
  letsencrypt_volume:
```

After running the command, access the UI at `http://<your_server_ip>:81`.  
Log in with the default credentials (`admin@example.com` / `changeme`), then configure proxy hosts and SSL settings as needed.

#### Add nginx-proxy-manager as a proxy host

Add Nginx Proxy Manager as a proxy host in itself. Create a new proxy host with the following settings:

- Domain Names: `nginx-proxy-manager.example.com`
- Scheme: `http`
- Forward Hostname/IP: `127.0.0.1`
- Forward Port: `81`
- Cache Assets: `Yes`
- Websockets Support: `Yes`
- Block Common Exploits: `Yes`
- SSL Support: `Yes`
- Force SSL: `Yes`
- HTTP/2 Support: `Yes`
- HSTS Policy: `Yes`
- HSTS Preload: `Yes`
- Custom Nginx Configuration:
  ```nginx
  location = /robots.txt {
    return 200 "User-agent: *\nDisallow: /\n";
  }
  ```

### Install Seq

Refer to the official [Seq documentation](https://hub.docker.com/r/datalust/seq) for the latest installation instructions.

📌 **TL;DR:**

```yaml
services:
  seq:
    image: datalust/seq:latest
    container_name: seq
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - "8081:80" # Web interface
    environment:
      - ACCEPT_EULA=Y
    volumes:
      - seq-data:/data
    networks:
      - shared-seq-network

volumes:
  seq-data:

networks:
  shared-seq-network:
    external: true
```

After running the command, access the UI at `http://<your_server_ip>:8081`.

#### Configure Seq

- Add the `GELP Input` app to Seq to allow Odoo to send logs to Seq.
- Add a retention policy to manage the amount of log data stored in Seq. For example, you can set a policy to delete logs older than 30 days.

### Install Grafana & Prometheus

Install Grafana to visualize monitoring data collected by Prometheus.

```yaml
services:
  prometheus:
    image: prom/prometheus:v2.55.0
    container_name: prometheus
    volumes:
      - /etc/opt/prometheus:/etc/prometheus:ro
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --storage.tsdb.retention.time=15d
      - --web.enable-lifecycle
    restart: unless-stopped

  grafana:
    image: grafana/grafana:11.3.0
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.51.0
    container_name: cadvisor
    command: 
      - --housekeeping_interval=10s
      - --docker_only=true
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/snap/docker/common/var-lib-docker:/var/lib/docker:ro
    ports:
      - "8080:8080"
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:v1.6.1
    container_name: node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

    ports:
      - "9100:9100"
    restart: unless-stopped

volumes:
  grafana-data:
  prometheus-data:
```

After running the command, access the UI at `http://<your_server_ip>:3000`.
Log in with the default credentials (`admin` / `admin`), then configure the Prometheus data source and import a dashboard as needed.

#### Import Dashboards

- [Docker monitoring](https://grafana.com/grafana/dashboards/193): 193
- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860): 1860

## Odoo in a Docker Container

### Dockerfile: Creating the Odoo Image

The `Dockerfile` defines the custom Odoo Docker image.

⚠️ **Warning:** The `Dockerfile` relies on a Python-based image without specifying a fixed Python version. This can lead to unexpected changes when new versions are released. If specifying a version, consider using a PPA (Personal Package Archive) for better control. However, be aware that at some point, certain images may no longer provide the specified version.

💡 **Note:** Seq is not included in Odoo's default setup. You may need to adjust Odoo.

The main steps performed are:

- Using Debian as a base: `debian:bullseye-slim` is chosen to ensure a lightweight and stable image.
- Installing system dependencies: Required packages such as build tools, fonts, and libraries are installed.
- Setting up PostgreSQL client: Allows Odoo to communicate with the database.
- Creating an Odoo user: The `odoo` user is created to run the application securely.
- Defining environment variables: Key paths such as `ODOO_HOME` and `ODOO_RC` are set.
- Exposing necessary ports: Odoo uses ports `8069`, `8071`, and `8072` for web, chat, and longpolling services.
- Configuring default Odoo directories: Directories for addons and data storage are defined.
- Installing Python dependencies: The `requirements.txt` file is used to install required Python libraries.
- Copying source files: The Odoo core, custom addons, and configuration files are included in the image.

```dockerfile
FROM debian:bullseye-slim

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for PostgreSQL and general locale data
ENV LANG=C.UTF-8

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        libpq-dev \
        libldap2-dev \
        libsasl2-dev \
        node-less \
        npm \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        python3-wheel \
        xz-utils \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get update && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install PostgreSQL client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (for right-to-left language support)
RUN npm install -g rtlcss

# Create Odoo user
RUN groupadd -r odoo && useradd -r -g odoo -m -d /home/odoo -s /bin/bash odoo

# Set Odoo environment variables
ENV ODOO_HOME=/opt/odoo
ENV PYTHONPATH="$ODOO_HOME:$PYTHONPATH"

# Create Odoo configuration file
RUN mkdir -p /etc/odoo && \
    chown odoo:odoo /etc/odoo && \
    echo "[options]" > /etc/odoo/odoo.conf && \
    echo "addons_path = /opt/odoo/odoo/addons,/opt/odoo/app_addons,/opt/odoo/custom_addons" >> /etc/odoo/odoo.conf && \
    echo "data_dir = /var/lib/odoo" >> /etc/odoo/odoo.conf && \
    chown odoo:odoo /etc/odoo/odoo.conf

# Create systemd service file
RUN mkdir -p /etc/systemd/system && \
    echo "[Unit]" > /etc/systemd/system/odoo.service && \
    echo "Description=Odoo Open Source ERP and CRM" >> /etc/systemd/system/odoo.service && \
    echo "After=network.target" >> /etc/systemd/system/odoo.service && \
    echo "" >> /etc/systemd/system/odoo.service && \
    echo "[Service]" >> /etc/systemd/system/odoo.service && \
    echo "Type=simple" >> /etc/systemd/system/odoo.service && \
    echo "User=odoo" >> /etc/systemd/system/odoo.service && \
    echo "Group=odoo" >> /etc/systemd/system/odoo.service && \
    echo "ExecStart=/usr/bin/odoo --config /etc/odoo/odoo.conf " >> /etc/systemd/system/odoo.service && \
    echo "KillMode=mixed" >> /etc/systemd/system/odoo.service && \
    echo "" >> /etc/systemd/system/odoo.service && \
    echo "[Install]" >> /etc/systemd/system/odoo.service && \
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/odoo.service && \
    chown odoo:odoo /etc/systemd/system/odoo.service

# Create Odoo binary
RUN mkdir -p /usr/bin && \
    echo "#!/usr/bin/env python3" > /usr/bin/odoo && \
    echo "" >> /usr/bin/odoo && \
    echo "# set server timezone in UTC before time module imported" >> /usr/bin/odoo && \
    echo "__import__('os').environ['TZ'] = 'UTC'" >> /usr/bin/odoo && \
    echo "import odoo" >> /usr/bin/odoo && \
    echo "" >> /usr/bin/odoo && \
    echo "if __name__ == \"__main__\":" >> /usr/bin/odoo && \
    echo "    odoo.cli.main()" >> /usr/bin/odoo && \
    chmod +x /usr/bin/odoo

# Copy entrypoint script, Odoo configuration file, and Odoo binary
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fix line endings in scripts
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix /usr/bin/odoo && \
    dos2unix /etc/odoo/odoo.conf && \
    dos2unix /entrypoint.sh && \
    dos2unix /etc/systemd/system/odoo.service

# Create odoo
RUN mkdir -p /var/lib/odoo && chown -R odoo /var/lib/odoo

# Install Odoo dependencies
COPY requirements.txt $ODOO_HOME/
RUN pip3 install --no-cache-dir -U pip setuptools wheel && \
    pip3 install --no-cache-dir -r $ODOO_HOME/requirements.txt

# Copy Odoo source files and custom addons
COPY --chown=odoo:odoo odoo $ODOO_HOME/odoo
COPY --chown=odoo:odoo app_addons $ODOO_HOME/app_addons
COPY --chown=odoo:odoo custom_addons $ODOO_HOME/custom_addons

# Expose volumes for Odoo data
VOLUME ["/var/lib/odoo"]

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Set default environment variables
ENV ODOO_RC=/etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chmod +x /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
```

### EntryPoint.sh: Configuring Odoo Container Execution

Add the `entrypoint.sh` script to configure the Odoo container execution. The script is a fork of the [Odoo Docker repository](https://github.com/odoo/docker/blob/master/16.0/entrypoint.sh)

💡 **Note:** Seq logging and colored configuration are not included in Odoo by default. You may need to adjust Odoo.

```bash
#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

if [ -n "${OVERRIDE_CONF_FILE}" ]; then
  if [ -n "${WORKERS}" ] ||
     [ -n "${MAX_CRON_THREADS}" ] ||
     [ -n "${LIMIT_MEMORY_SOFT}" ] ||
     [ -n "${LIMIT_MEMORY_HARD}" ] ||
     [ -n "${LIMIT_TIME_CPU}" ] ||
     [ -n "${LIMIT_TIME_REAL}" ] ||
     [ -n "${LIMIT_REQUEST}" ] ||
     [ -n "${LIST_DB}" ] ||
     [ -n "${PROXY_MODE}" ] ||
     [ -n "${ADMIN_PASSWD}" ] ||
     [ -n "${SERVER_WIDE_MODULES}" ] ||
     [ -n "${SEQ_ADDRESS}" ]; then

    echo "Error: The following environment variables cannot be set when using a custom Odoo configuration:"
    echo "       WORKERS, MAX_CRON_THREADS, LIMIT_MEMORY_SOFT, LIMIT_MEMORY_HARD, LIMIT_TIME_CPU, LIMIT_TIME_REAL, LIMIT_REQUEST, LIST_DB, PROXY_MODE, ADMIN_PASSWD, SERVER_WIDE_MODULES, SEQ_ADDRESS"
    exit 1
  fi
fi

: ${WORKERS:=0}
: ${MAX_CRON_THREADS:=1}
: ${LIMIT_MEMORY_SOFT:=2147483648}
: ${LIMIT_MEMORY_HARD:=2684354560}
: ${LIMIT_TIME_CPU:=60}
: ${LIMIT_TIME_REAL:=120}
: ${LIMIT_REQUEST:=65536}

: ${LIST_DB:='True'}
: ${PROXY_MODE:='False'}

: ${COLOR_CODE:='71639E'}

if [ -n "${OVERRIDE_CONF_FILE}" ]; then
    echo "Applying custom Odoo configuration."
    echo "${OVERRIDE_CONF_FILE}" > /etc/odoo/odoo.conf
else
    echo "Restoring default Odoo configuration."
    cat <<EOL > /etc/odoo/odoo.conf
[options]
addons_path = /opt/odoo/odoo/addons,/opt/odoo/app_addons,/opt/odoo/custom_addons
data_dir = /var/lib/odoo
EOL
    chown odoo:odoo /etc/odoo/odoo.conf
fi

if [ -z "${OVERRIDE_CONF_FILE}" ]; then
  if [ -n "${SEQ_ADDRESS}" ]; then
      # If SEQ_ADDRESS is set, update or add log_seq in odoo.conf
      if grep -q -E "^\s*log_seq\s*=" "$ODOO_RC" ; then
          sed -i "s/^\s*log_seq\s*=.*/log_seq = ${SEQ_ADDRESS}/" "$ODOO_RC"
      else
          echo "log_seq = ${SEQ_ADDRESS}" >> "$ODOO_RC"
      fi
  else
      # If SEQ_ADDRESS is not set, remove the log_seq line from odoo.conf
      sed -i "/^\s*log_seq\s*=/d" "$ODOO_RC"
  fi

  if [ -n "${ADMIN_PASSWD}" ]; then
      # If ADMIN_PASSWD is set, update or add admin_passwd in odoo.conf
      if grep -q -E "^\s*admin_passwd\s*=" "$ODOO_RC" ; then
          sed -i "s/^\s*admin_passwd\s*=.*/admin_passwd = ${ADMIN_PASSWD}/" "$ODOO_RC"
      else
          echo "admin_passwd = ${ADMIN_PASSWD}" >> "$ODOO_RC"
      fi
  else
      # If ADMIN_PASSWD is not set, remove the admin_passwd line from odoo.conf
      sed -i "/^\s*admin_passwd\s*=/d" "$ODOO_RC"
  fi

  if [ -n "${SERVER_WIDE_MODULES}" ]; then
      # If SERVER_WIDE_MODULES is set, update or add server_mode in odoo.conf
      if grep -q -E "^\s*server_wide_modules\s*=" "$ODOO_RC" ; then
          sed -i "s/^\s*server_wide_modules\s*=.*/server_wide_modules = ${SERVER_WIDE_MODULES}/" "$ODOO_RC"
      else
          echo "server_wide_modules = ${SERVER_WIDE_MODULES}" >> "$ODOO_RC"
      fi
  else
      # If SERVER_WIDE_MODULES is not set, remove the server_wide_modules line from odoo.conf
      sed -i "/^\s*server_wide_modules\s*=/d" "$ODOO_RC"
  fi
fi

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

ODOO_ARGS=("${DB_ARGS[@]}")

if [ -n "${UPDATE}" ]; then
    ODOO_ARGS+=("--update=${UPDATE}")
fi
if [ -z "${OVERRIDE_CONF_FILE}" ]; then
  ODOO_ARGS+=("--workers=${WORKERS}")
  ODOO_ARGS+=("--max-cron-threads=${MAX_CRON_THREADS}")
  ODOO_ARGS+=("--limit-memory-soft=${LIMIT_MEMORY_SOFT}")
  ODOO_ARGS+=("--limit-memory-hard=${LIMIT_MEMORY_HARD}")
  ODOO_ARGS+=("--limit-time-cpu=${LIMIT_TIME_CPU}")
  ODOO_ARGS+=("--limit-time-real=${LIMIT_TIME_REAL}")
  ODOO_ARGS+=("--limit-request=${LIMIT_REQUEST}")
  if [ -n "${LIST_DB}" ] && [ "${LIST_DB}" = "False" ]; then
      ODOO_ARGS+=("--no-database-list")
  fi
  if [ -n "${PROXY_MODE}" ] && [ "${PROXY_MODE}" = "True" ]; then
      ODOO_ARGS+=("--proxy-mode")
  fi
fi

# Change color in colors.scss
if [ -f /opt/odoo/app_addons/color_theme/static/src/colors.scss ]; then
    sed -i "s/#7B92AD/#${COLOR_CODE}/g" /opt/odoo/app_addons/color_theme/static/src/colors.scss
    echo "Color changed to #${COLOR_CODE} in colors.scss."
else
    echo "File /opt/odoo/app_addons/color_theme/static/src/colors.scss not found."
fi

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            echo odoo "$@" "${ODOO_ARGS[@]}"
            exec odoo "$@" "${ODOO_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        echo odoo "$@" "${ODOO_ARGS[@]}"
        exec odoo "$@" "${ODOO_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
```

### wait-for-psql.py: Ensuring PostgreSQL Readiness

Add the `wait-for-psql.py` script available from [Odoo Docker repository](https://github.com/odoo/docker/blob/master/16.0/wait-for-psql.py) to ensure that Odoo does not start until PostgreSQL is available.

### Running Odoo with Docker Compose

The `docker-compose.yml` file defines the services required to run Odoo with PostgreSQL.

💡 **Note**: Seq is not included in the services configuration. To centralize all logs in a single Seq instance, create a shared network for Seq and run an additional service to forward logs to Seq.

Configuration options:

| Variable           | Description                              | Valeur par défaut |
|--------------------|------------------------------------------|-------------------|
| HOST               | PostgreSQL database host                 | db                |
| PORT               | PostgreSQL database port                 | 5432              |
| USER               | PostgreSQL database user                 | odoo              |
| PASSWORD           | PostgreSQL database password             | odoo              |
| WORKERS            | Nombre de processus workers              | 0                 |
| MAX_CRON_THREADS   | Nombre max de threads cron               | 1                 |
| LIMIT_MEMORY_SOFT  | Limite mémoire soft                      | 2147483648        |
| LIMIT_MEMORY_HARD  | Limite mémoire hard                      | 2684354560        |
| LIMIT_TIME_CPU     | Limite temps CPU (secondes)              | 60                |
| LIMIT_TIME_REAL    | Limite temps réel d'exécution (secondes) | 120               |
| LIMIT_REQUEST      | Limite du nombre de requêtes             | 65536             |
| LIST_DB            | Autoriser la liste des bases de données  | True              |
| PROXY_MODE         | Activer le mode proxy                    | False             |
| COLOR_CODE         | Code hexadécimal du thème                | N/A               |
| SEQ_ADDRESS        | Adresse pour Seq logging                 | N/A               |
| ADMIN_PASSWD       | Mot de passe administrateur Odoo         | N/A               |
| SERVER_WIDE_MODULES| Liste des modules serveur larges         | N/A               |
| OVERRIDE_CONF_FILE | Fichier de configuration personnalisé    | N/A               |

When using a custom configuration file (`OVERRIDE_CONF_FILE`), the script will not apply the default settings. Ensure that the custom configuration file contains all necessary settings.

The main services defined are:

```yaml
services:
  web:
    image: <IMAGE>:<IMAGE_TAG>
    depends_on:
      - db
    healthcheck:
      test: ["CMD", "curl", "-f", "-X", "POST", "-H", "Content-Type: application/json", "-H", "Accept: application/json", "-d", "{\"jsonrpc\":\"2.0\",\"method\":\"call\",\"params\":{},\"id\":1}", "http://localhost:8069/web/webclient/version_info"]
      interval: 60s
      timeout: 10s
      retries: 3
      start_period: 60s
    ports:
      # These ports are in format <host-port>:<container-port>
      - "29204:8069"
      - "29205:8072"
    environment:
      COLOR_CODE: 71639E
      PROXY_MODE: True
      LIST_DB: False
      WORKERS: 2
      MAX_CRON_THREADS: 0
      SEQ_ADDRESS: seq:12201
      ADMIN_PASSWD: odoo
      # - UPDATE=ALL
    volumes:
      - web-data:/var/lib/odoo
    networks:
      - project-internal-network
      - shared-seq-network

  db:
    image: postgres:17
    environment:
      POSTGRES_DB: postgres
      POSTGRES_PASSWORD: odoo
      POSTGRES_USER: odoo
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - project-internal-network
      - shared-pgadmin4-network

volumes:
  web-data:
  db-data:

networks:
  project-internal-network:
    driver: bridge
  shared-seq-network:
    external: true
```

### DevOps Build Pipeline for Docker Image

This pipeline automates the building and pushing of Odoo Docker images. It runs on Git tags (`refs/tags/*`), using the tag (e.g., `v16.0.1`) as the Docker image tag. If no tag is found, it defaults to the first seven characters of the commit hash.

The process extracts the version, builds the Docker image with the detected tag, and pushes it to the Docker registry.

```yaml
trigger:
  branches:
    include:
      - refs/tags/*

jobs:
- job: Build_and_Push
  displayName: Build and Push Docker Image
  pool:
    name: DOCKER

  steps:
  - checkout: self

  - task: Bash@3
    displayName: Extract Version (Tag or Commit Hash)
    inputs:
      targetType: inline
      script: |
        if [[ "$(Build.SourceBranch)" == refs/tags/* ]]; then
            dockertag=$(echo $(Build.SourceBranch) | sed -e "s/^refs\/tags\///")
            echo "##vso[task.setvariable variable=dockertag;]$dockertag"
            echo "Version tag detected: $dockertag"
        else
            dockertag=$(echo $(Build.SourceVersion) | cut -c-7)
            echo "##vso[task.setvariable variable=dockertag;]$dockertag"
            echo "No tag detected, using commit hash: $dockertag"
        fi

  - task: Docker@2
    displayName: Build and Push Docker Image
    inputs:
      containerRegistry: 'Registry'
      repository: $(Build.Repository.Name)
      tags: $(dockertag)
```

For greater control over the build and push process, the separates the Docker@2 build and push commands:

```yaml
- task: Docker@2
  displayName: Build
  inputs:
    containerRegistry: 'Registry'
    repository: '$(Build.Repository.Name)'
    command: build
    tags: '$(dockertag)'

- task: Docker@2
  displayName: Push
  inputs:
    containerRegistry: 'Registry'
    repository: '$(Build.Repository.Name)'
    command: push
    tags: '$(dockertag)'
```
