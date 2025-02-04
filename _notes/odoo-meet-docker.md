---
layout: note
title: Odoo & Docker
draft: false
date: 2024-11-14 14:44:00 +0200
author: Victor Hachard
categories: ['Docker', 'Odoo', 'System Administration']
---

## Introduction

These instructions provide a comprehensive guide to deploying Odoo with Docker, including setting up a private registry, reverse proxy, and centralized logging, creating a custom Odoo image, configuring the container execution, and integrating with PostgreSQL and Seq for logging.

⚠️ **Warning:** The following guide is a working example for Odoo 16.0 on ubuntu 24.04.1 LTS early 2025.

## Skills needed

- **Containerization & Orchestration**  
  - **Docker**: Image creation, container management, volumes, and networks.  
  - **Docker Compose**: Orchestrating multiple services with `docker-compose.yml`.

- **Image Management & Registries**  
  - **Docker Private Registry**: Setting up and managing a private registry for custom images.

- **Infrastructure & Administration**  
  - **Portainer**: Web interface for managing Docker and Docker Compose.  
  - **Linux Administration**: Filesystem, permissions, users, and process management.

- **Reverse Proxy & Security**  
  - **Nginx Proxy Manager**: GUI for configuring Nginx as a reverse proxy.  
  - **Nginx**: Web server and reverse proxy.

- **Databases**  
  - **PostgreSQL**: Managing Odoo's database (SQL commands, users, backups, and restores).

- **Development & Logging**  
  - **Odoo**: Understanding Odoo's architecture and containerized execution.  
  - **Seq**: Centralized log management for system and application events.  
  - **Bash & Automation**: Scripting for log management, container cleanup, and task automation.

- **CI/CD & Automation**  
  - **Git**: Source code management and version control.  
  - **CI/CD with GitHub Actions & DevOps**: Automating builds and deployments.  
  - **Webhooks & DevOps Pipelines**: Creating workflows for container build, test, and deployment automation.

- **Networking & Container Communication**  
  - **DNS & Internal Routing**: Configuring service communication and internal domain management with Docker.

## Server Setup

### Install Docker

Docker is a platform for developing, shipping, and running applications in containers. You can install Docker on your server using Snap or apt.

#### Install Docker with Snap

Docker can be installed using Snap during the Ubuntu setup or manually afterward.

⚠️ **Warning:** To prevent unexpected interruptions due to automatic updates, configure Snap to control Docker updates.

First, check the current refresh schedule:

```bash
sudo snap refresh --time
```

Then, set a specific update window to limit when Docker updates can occur (e.g., every Monday between 03:15 and 03:30 AM):

```bash
sudo snap set system refresh.timer=mon,3:15-3:30
```

This ensures that Docker updates only during the defined time, reducing the risk of unexpected downtime.

#### Install Docker with apt

You can install Docker on your server by running the following commands:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

After adding the Docker repository, you can install Docker by running the following command:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### Install Portainer

Portainer is a lightweight management UI that allows you to easily manage your Docker environments. You can install Portainer using Docker by running the following command:

```bash
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.4
```

After running the command, access the UI at `http://<your_server_ip>:9443`.

### Install Docker Registry

A **Docker registry** is a system for storing and delivering Docker images, allowing you to manage different versions using tags. You can deploy a registry on your server using the following **Docker Compose** configuration:

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

To link the registry to Portainer, navigate to the Portainer dashboard and add a new registry endpoint with the following details:

- Name: `Odoo Registry`
- Endpoint URL: `https://odoo-registry.example.com`
- Authentication: `Yes`
- Username: `USERNAME`
- Password: `PASSWORD`

#### Create a User for the Registry

To secure your registry, create a new user by generating a bcrypt-encrypted password and storing it in the `htpasswd` file:

```bash
docker run --entrypoint htpasswd httpd:2 -Bbn USERNAME PASSWORD > PATH_TOVOLUME/htpasswd
```

Alternatively, manually add a new user to the `htpasswd` file:

```bash
echo 'USERNAME:BCRYPT_PASSWORD' >> /auth/htpasswd
```

#### List Images and Tags in the Registry

##### List all images in the registry:

```bash
curl -X GET -u USERNAME:PASSWORD https://odoo-registry.example.com/v2/_catalog
```

Or access the catalog via a web browser:

```
https://odoo-registry.example.com/v2/_catalog
```

##### List all tags of a specific image:

```bash
curl -u USERNAME:PASSWORD https://odoo-registry.example.com/v2/IMAGE_NAME/tags/list
```

Or open the following URL in your browser:

```
https://odoo-registry.example.com/v2/IMAGE_NAME/tags/list
```

### Install Nginx Proxy Manager

Nginx Proxy Manager provides a simple UI for managing reverse proxies and SSL certificates. You can install Nginx Proxy Manager using Docker by running the following command:

```yaml
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
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

Seq is a log server that collects, stores, and analyzes log data. You can install Seq using Docker by running the following command:

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

#### Add an Apps to allow odoo to send logs to Seq

Add the `GELP Input` app to Seq to allow Odoo to send logs to Seq.

#### Add a retention policy

Add a retention policy to manage the amount of log data stored in Seq. For example, you can set a policy to delete logs older than 30 days.

### Add a Grafana Dashboard

Grafana is a open-source analytics and monitoring platform combined with prometheus and cadvisor to monitor the server. You can install Grafana using Docker by running the following command:

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

#### Import a Dashboard

Import a pre-built dashboard to visualize the monitoring data collected by Prometheus. You can find a variety of dashboards on the Grafana website or create your own custom dashboards.

Recommended dashboards:
- [Docker monitoring](https://grafana.com/grafana/dashboards/193): 193
- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860): 1860

## Installing and Configuring Odoo in a Docker Container

### Dockerfile: Creating the Odoo Image

The `Dockerfile` defines the custom Odoo Docker image.

💡 **Note:** Seq is not included in Odoo's default setup. You may need to adjust the logging configuration to integrate with Seq.

The main steps performed are:

- **Using Debian as a base**: `debian:bullseye-slim` is chosen to ensure a lightweight and stable image.
- **Installing system dependencies**:
  - `build-essential`: Required for compiling certain Odoo dependencies.
  - `python3, python3-dev, python3-pip`: Necessary for running Python-based Odoo.
  - `libpq-dev, libldap2-dev, libsasl2-dev`: PostgreSQL and authentication-related libraries.
  - `wkhtmltopdf`: Required for generating PDF reports in Odoo.
- **Setting up PostgreSQL client**: Allows Odoo to communicate with the database.
- **Creating an Odoo user**: The `odoo` user is created to run the application securely.
- **Defining environment variables**: Key paths such as `ODOO_HOME` and `ODOO_RC` are set.
- **Exposing necessary ports**: Odoo uses ports `8069`, `8071`, and `8072` for web, chat, and longpolling services.
- **Configuring default Odoo directories**: Directories for addons and data storage are defined.
- **Installing Python dependencies**: The `requirements.txt` file is used to install required Python libraries.
- **Copying source files**: The Odoo core, custom addons, and configuration files are included in the image.

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

The `entrypoint.sh` script is responsible for initializing the Odoo container with proper environment settings.

💡 **Note:** Seq and colored logging are not included in Odoo by default. You may need to adjust the logging configuration to integrate with Seq.

#### **Key Tasks Performed by entrypoint.sh**
- **Database connection settings**:
  - Reads PostgreSQL credentials from environment variables (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`).
  - Passes them as arguments to the Odoo process if not defined in the config file.

- **Dynamic Odoo configuration**:
  - If `OVERRIDE_CONF_FILE` is not provided, it sets default values for:
    - Number of workers.
    - Memory and CPU limits.
    - Proxy mode settings.
    - Admin password.

- **Logging integration with Seq**:
  - If `SEQ_ADDRESS` is set, it enables Seq logging in `odoo.conf`.
  - Otherwise, it removes Seq-related configuration.

- **Database readiness check**:
  - Uses `wait-for-psql.py` (detailed below) to ensure the PostgreSQL database is ready before launching Odoo.

- **Customization of Odoo UI**:
  - Changes the theme color by modifying `colors.scss`, if applicable.

- **Executing Odoo**:
  - Depending on the input command, either runs Odoo normally or executes administrative tasks like scaffolding new modules.

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
# Append --update and --workers if applicable
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

The `wait-for-psql.py` script ensures that Odoo does not start until PostgreSQL is available. This prevents startup failures due to database unavailability.

💡 **Note:** The script is available in the Odoo Docker repository on GitHub. Make sure to use the version that matches your Odoo version.

#### **How it Works**
1. Accepts database connection parameters (`host`, `port`, `user`, `password`) as arguments.
2. Repeatedly attempts to connect to PostgreSQL.
3. If the connection is successful, the script exits normally.
4. If the timeout limit is reached, it prints an error and exits with failure.

```python
import psycopg2
import sys
import time
import argparse

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--db_host', required=True)
    arg_parser.add_argument('--db_port', required=True)
    arg_parser.add_argument('--db_user', required=True)
    arg_parser.add_argument('--db_password', required=True)
    arg_parser.add_argument('--timeout', type=int, default=5)

    args = arg_parser.parse_args()

    start_time = time.time()
    while (time.time() - start_time) < args.timeout:
        try:
            conn = psycopg2.connect(
                user=args.db_user, 
                host=args.db_host, 
                port=args.db_port, 
                password=args.db_password, 
                dbname='postgres'
            )
            conn.close()
            error = ''
            break
        except psycopg2.OperationalError as e:
            error = e
        time.sleep(1)

    if error:
        print("Database connection failure: %s" % error, file=sys.stderr)
        sys.exit(1)
```

### Running Odoo with Docker Compose

The `docker-compose.yml` file defines the services required to run Odoo with PostgreSQL.

💡 **Note**: Seq is not included in the services configuration. To centralize all logs in a single Seq instance, create a shared network for Seq and run an additional service to forward logs to Seq.

Configuration options:

| Variable            | Description                               | Valeur par défaut |
|---------------------|-------------------------------------------|-------------------|
| HOST               | PostgreSQL database host                 | db               |
| PORT               | PostgreSQL database port                 | 5432             |
| USER               | PostgreSQL database user                 | odoo             |
| PASSWORD           | PostgreSQL database password             | odoo             |
| WORKERS            | Nombre de processus workers              | 0                |
| MAX_CRON_THREADS   | Nombre max de threads cron               | 1                |
| LIMIT_MEMORY_SOFT  | Limite mémoire soft                      | 2147483648       |
| LIMIT_MEMORY_HARD  | Limite mémoire hard                      | 2684354560       |
| LIMIT_TIME_CPU     | Limite temps CPU (secondes)              | 60               |
| LIMIT_TIME_REAL    | Limite temps réel d'exécution (secondes) | 120              |
| LIMIT_REQUEST      | Limite du nombre de requêtes             | 65536            |
| LIST_DB            | Autoriser la liste des bases de données  | True             |
| PROXY_MODE         | Activer le mode proxy                    | False            |
| COLOR_CODE         | Code hexadécimal du thème                | 71639E           |
| SEQ_ADDRESS        | Adresse pour Seq logging                 | seq:12201        |
| ADMIN_PASSWD       | Mot de passe administrateur Odoo         | odoo             |
| SERVER_WIDE_MODULES| Liste des modules serveur larges         | N/A              |
| OVERRIDE_CONF_FILE | Fichier de configuration personnalisé    | N/A              |

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

### **DevOps Build Pipeline for Docker Image**

This pipeline automates the building and pushing of Odoo Docker images with proper versioning.

#### **Trigger and Versioning:**
- The pipeline **only runs on Git tags** (`refs/tags/*`), ensuring only versioned releases are built.
- If a Git tag exists (e.g., `v16.0.1`), it is used as the Docker tag.
- If no tag is found, it falls back to the **first 7 characters** of the commit hash.

#### **Build & Push Process:**
1. **Extract version**: Detects a Git tag or falls back to the commit hash.
2. **Builds Docker image** with the extracted tag.
3. **Pushes the image** to the Azure DevOps Docker registry.

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
      containerRegistry: DEVOPS_DOCKER_REGISTRY
      repository: $(Build.Repository.Name)
      tags: $(dockertag)
```
