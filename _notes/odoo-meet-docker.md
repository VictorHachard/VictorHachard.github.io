---
layout: note
title: Odoo Deployment with Docker
draft: false
active: false
date: 2024-11-14 14:44:00 +0200
author: Victor Hachard
categories: ['Docker', 'Odoo', 'CI/CD', 'System Administration']
---

⚠️ **Warning:** tested on Odoo 11.0, 15.0, 16.0, 17.0, and 18.0 with Ubuntu 24.04.1 LTS in early 2025.

## Overview  

This guide covers private registry, reverse proxy, logging, custom image creation, container execution, PostgreSQL, and Seq integration.

### Architecture Diagram

<div style="overflow-x: scroll;">
<pre class="mermaid" style="width: 200%;">
sequenceDiagram
  participant Dev as Developer
  participant CI as CI/CD Pipeline
  participant Dockerfile
  participant Entrypoint
  participant Registry as Docker Registry
  participant Portainer
  participant Compose as Docker Compose
  participant Odoo
  participant PG as PostgreSQL
  participant Seq
  participant Grafana
  participant NPM as Nginx Proxy Manager
  participant CF as Cloudflare
  participant User

  Dev->>CI: Tag Commit / Push
  CI->>Dockerfile: Build Odoo Image
  Dockerfile->>Entrypoint: Inject Runtime Config (SEQ, THEME, ENV)
  Entrypoint-->>Dockerfile: Ready for Image Build
  CI->>Registry: Push Built Image
  Portainer->>Registry: Pull Image
  Portainer->>Compose: Deploy Stack
  Compose->>Odoo: Launch Container
  Compose->>PG: Start DB
  Odoo->>Seq: Send Logs (via GELF)
  Compose->>Grafana: Expose Metrics (via Prometheus Exporters)
  Odoo->>NPM: Expose Web Interface
  NPM->>CF: Public Reverse Proxy
  User->>CF: Access https://odoo.example.com
  CF->>NPM: Forward Request
  NPM->>Odoo: Serve Response
</pre>
</div>

### Old Architecture Diagram

<pre class="mermaid">
flowchart LR
  A[Define Dockerfile] -->|Pipeline Execution| DP -->|Push| C[Docker Registry]
  
  subgraph DP[DevOps Pipeline]
    direction TB
    B1[Trigger Pipeline] --> B2[Build Odoo Image] --> B3[Push to Registry]
  end

  C -->|Pull| D1
  D3[Docker Hub] -->|Pull| D2
  
  subgraph DCD[Docker Compose Deployment]
    D1[Odoo Container]
    D2[PostgreSQL Container]
  end
  
  DCD -->|Serve| F[Odoo Application]
</pre>

### Access Diagram

<pre class="mermaid">
flowchart LR
  O[Operators with Browser]
  O -->|Access| CF[Cloudflare]
  CF -->|Proxy| N[Nginx Reverse Proxy]
  subgraph Docker
    N -->|Frontend| Odoo[Odoo Application]
  end
</pre>

### Typical workflow

- Developers build the project and push the resulting image to the private registry.
- Operators deploy or update the Docker Compose stack via Portainer.
- Alternatively, tagging a commit can automatically trigger a new build and push.
- Advanced Nginx rules are managed through Nginx Proxy Manager, with Cloudflare handling the public DNS and proxy layer.

### Points for Enhancement

- Auto-prune old builds in the private registry
- Versioned Nginx configuration stored in source control and mounted into the Nginx container as part of the stack
- Add an Nginx configuration to retrieve the client’s IP address variable instead of Cloudflare’s when proxying (TODO a guide for this linked to *Real IP with Cloudflare*)

## Server Setup

### Network Prerequisites

#### Required Open Ports

Ensure these ports are reachable on your server so that each service can communicate and be accessed:

| Service / Container           | Port              |
| ----------------------------- | ----------------- |
| **SSH**                       | 2233 and 22       |
| **HTTP (global web)**         | 80                |
| **HTTPS (global web)**        | 443               |
| **Portainer CE**              | 9443              |
| **Nginx Proxy Manager UI**    | 81                |
| **Docker Registry**           | 5000              |
| **Seq (logs UI)**             | 8081              |
| **cAdvisor (metrics)**        | 8080              |
| **Node Exporter (metrics)**   | 9100              |
| **Prometheus (metrics + UI)** | 9090              |
| **Grafana (dashboard UI)**    | 3000              |

#### DNS Records

Point the following hostnames to your server’s public IP so users and tools can reach each interface through the reverse proxy:

| Service / Container           | DNS Record Name                   |
| ----------------------------- | --------------------------------- |
| **Portainer CE**              | `portainer.example.com`           |
| **Nginx Proxy Manager**       | `nginx-proxy-manager.example.com` |
| **Docker Registry**           | `registry.example.com`            |
| **Seq (logs)**                | `seq.example.com`                 |
| **Grafana (dashboard)**       | `grafana.example.com`             |
| **Prometheus (metrics)**      | `prometheus.example.com`          |

Once DNS is in place, you can safely close these service ports at the firewall and expose them only via your reverse-proxy layer.

### Prerequisites

- Updating and upgrading the system
- Setting the timezone (Europe/Brussel)
- Installing and configuring ufw (allow SSH, HTTP, HTTPS)
- Installing and activate unattended upgrades (activate: Distro-Update, Remove-Unused-Kernel-Packages, Remove-New-Unused-Dependencies, Remove-Unused-Dependencies, Automatic-Reboot, Automatic-Reboot-Time)
- Updating the SSH port (from 22 to 2233)

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

# Update the SSH port
sudo sed -i "s/#Port 22/Port 2233/g" /etc/ssh/sshd_config
```

💡 **Note:** To streamline secure access to your Odoo hosts, see [SSH Key Setup for Fast, Secure Connections on Windows with PuTTY](https://victorhachard.github.io/notes/ssh-key-setup-for-fast-secure-connections).

⚠️ **Warning:** For improved security, switch from password-based logins to SSH key authentication. After you’ve set up SSH keys for every user, disable all password-based login methods.
  ```bash
  sudo sed -i \
    -e 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
    -e 's/^#*UsePAM.*/UsePAM no/' \
    /etc/ssh/sshd_config
  ```

💡 **Note:** To allow a user to run sudo commands without entering a password, add a NOPASSWD rule to their sudoers file. For example:
  ```bash
  sudo nano /etc/sudoers.d/<username>

  # Add this line:
  <username> ALL=(ALL) NOPASSWD:ALL
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

After running the command, access the UI at `https://<your_server_ip>:9443`.

💡 Note: Implement a cleanup script on your host to reclaim the disk space occupied by unused Docker images. For a detailed walkthrough, see [Automated Cleanup Unused Docker Images.](https://victorhachard.github.io/notes/automated-cleanup-unused-docker-images)

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

#### Create a User for the Registry

To secure the registry, create a new user by generating a bcrypt-encrypted password and storing it in the `htpasswd` file:

```bash
docker run --entrypoint htpasswd httpd:2 -Bbn USERNAME PASSWORD > PATH_TOVOLUME/htpasswd
```

Alternatively, manually add a new user to the `htpasswd` file using the following command:

```bash
docker run --entrypoint htpasswd httpd:2 -Bbn USERNAME PASSWORD
```

Then append the output to the `htpasswd` file in the registry's auth volume:

```bash
echo 'USERNAME:BCRYPT_PASSWORD' >> /auth/htpasswd
```

Be sure that there is two lines in the file: one for the new user and one for the existing user (if any).

#### Link the Registry to Portainer

Refer to the official [Portainer documentation](https://docs.portainer.io/admin/registries/add/custom#:~:text=From%20the%20menu%20select%20Registries,enter%20the%20username%20and%20password.) for detailed instructions.

📌 **TL;DR:** Navigate to the Portainer dashboard and add a new registry endpoint with the following details:

- Name: `Odoo Registry`
- Endpoint URL: `https://registry.example.com`
- Authentication: `Yes`
- Username: `USERNAME`
- Password: `PASSWORD`

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

#### Add server block for Odoo

To expose your Odoo instance via Nginx Proxy Manager, create a dedicated server block. Below are guides for different Odoo versions:

- **Odoo 11 and 15**: [Server Block for Odoo 11 and 15](https://victorhachard.github.io/notes/nginx-server-block-odoo-11-15)
- **Odoo 16 and 17**: [Server Block for Odoo 16 and 17](https://victorhachard.github.io/notes/nginx-server-block-odoo-16-17)

#### Real IP with Cloudflare

To ensure that Nginx Proxy Manager correctly identifies the real IP address of clients when using Cloudflare, add the following configuration to your Nginx Proxy Manager server block:

```nginx
set_real_ip_from x.x.x.x/xx; # Replace with Cloudflare's IP ranges

real_ip_header CF-Connecting-IP;
real_ip_recursive on;
```

Refer to [Cloudflare's current list of IP addresses](https://www.cloudflare.com/ips-v4) for the latest IP ranges to include in the `set_real_ip_from` directive.

#### TLS Certificates

With Cloudflare Proxy:

- In your Cloudflare dashboard, download the Origin Certificate.
- Upload and install this certificate (along with its private key) in Nginx Proxy Manager.

Cloudflare DNS-Only or Other DNS Providers:

Use the built-in Let’s Encrypt integration in Nginx Proxy Manager to automatically issue and renew your certificate.

### Install Seq

Refer to the official [Seq documentation](https://hub.docker.com/r/datalust/seq) for the latest installation instructions.

📌 **TL;DR:**

Create a docker network for Seq to allow Odoo to send logs to it:

```bash
docker network create shared-seq-network
```

Or in portainer, go to `Networks` → `Add Network` and create a new network named `shared-seq-network`.

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
      - SEQ_PASSWORD=your_password_here # Set a strong password
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
Log in with the default credentials (`admin` / `your_password_here`), then configure Seq as needed.
After changing the password, remove the `SEQ_PASSWORD` environment variable.

#### Configure Seq

- Add the `GELF Input` app to Seq to allow Odoo to send logs to Seq (Settings → Apps → Add App → GELP Input). Then add an instance of the GELF Input app with the following settings:
  - Name: `Odoo`
- Add a retention policy to manage the amount of log data stored in Seq (Data → Storage → Add Retention Policies). For example, you can set a policy to delete logs older than 30 days.

### Install Grafana & Prometheus

Install Grafana to visualize monitoring data collected by Prometheus.

Create a file named `prometheus.yml` in `/etc/opt/prometheus` with the following content:

```yaml
global:
  scrape_interval: 15s
 
scrape_configs:
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

This configuration sets up Prometheus to scrape metrics from cAdvisor and Node Exporter every 15 seconds.

```yaml
services:
  prometheus:
    image: prom/prometheus:v2.55.0
    container_name: prometheus
    volumes:
      - /etc/opt/prometheus:/etc/prometheus:ro
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"  # Optional don't needed if you use internal network
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
Log in with the default credentials (`admin` / `admin`).
Configure the Prometheus data source in Grafana with the URL `http://<your_server_ip>:9090` or `http://prometheus:9090`

#### Import Dashboards

- [Docker monitoring](https://grafana.com/grafana/dashboards/193): 193
- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860): 1860

### Install docker-autoheal

Install `docker-autoheal` to automatically restart unhealthy containers. The service will monitor the health of all containers and restart them if they become unhealthy.

```yaml
services:
  autoheal:
    image: willfarrell/autoheal:latest
    container_name: autoheal
    restart: unless-stopped
    environment:
      - AUTOHEAL_CONTAINER_LABEL=all
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock
```

## Odoo in a Docker Container

### Dockerfile: Creating the Odoo Image

To deploy Odoo in a Docker container, you need to create a customized Odoo image. Below are guides for different Odoo versions:

- **Odoo 11**: [Docker Setup for Long-Term Odoo 11 Deployment](https://victorhachard.github.io/notes/odoo-11-dockerfile)
- **Odoo 15**: [Docker Setup for Long-Term Odoo 15 Deployment](https://victorhachard.github.io/notes/odoo-15-dockerfile)
- **Odoo 16**: [Docker Setup for Long-Term Odoo 16 Deployment](https://victorhachard.github.io/notes/odoo-16-dockerfile)
- **Odoo 17**: [Docker Setup for Long-Term Odoo 17 Deployment](https://victorhachard.github.io/notes/odoo-17-dockerfile)

### Update `entrypoint.sh`

The `entrypoint.sh` script is essential for configuring the Odoo container at runtime. Follow this guide for modifying the script: [entrypoint.sh for Odoo Docker](https://victorhachard.github.io/notes/odoo-docker-entrypoint).

#### Add Seq Logging

To add Seq logging to Odoo refer to [Configuring Odoo Logging to Seq with pygelf](https://victorhachard.github.io/notes/odoo-add-seq-logger).

Update the `entrypoint.sh` script :

- Add in the `disallowed_vars` list `'SEQ_ADDRESS'`.
- Then add the following code snippet to the `entrypoint.sh`:
  ```bash
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
  fi
  ```

Define `SEQ_ADDRESS` in the Docker environment:
  
```yaml
environment:
  SEQ_ADDRESS: seq:12201
```

#### Add a Custom Color Theme

🎯 **TODO:** Update this guide to add the module to allow color theme.

Update the `entrypoint.sh` script to add a custom color theme:

```bash
# Change color in colors.scss
if [ -f /opt/odoo/app_addons/color_theme/static/src/colors.scss ]; then
  sed -i "s/#7B92AD/#${COLOR_CODE}/g" /opt/odoo/app_addons/color_theme/static/src/colors.scss
  echo "Color changed to #${COLOR_CODE} in colors.scss."
else
  echo "File /opt/odoo/app_addons/color_theme/static/src/colors.scss not found."
fi
```

Define `COLOR_CODE` in the Docker environment:

```yaml
environment:
  COLOR_CODE: 71639E
```

### Running Odoo with Docker Compose

The `docker-compose.yml` file defines the services required to run Odoo with PostgreSQL.

The main services defined are:

```yaml
services:
  web:
    image: <IMAGE>:<IMAGE_TAG>
    restart: unless-stopped
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
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "odoo"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    shm_size: 256mb  # Increase shared memory size for PostgreSQL (optional if there are issues like "could not resize shared memory segment")
    environment:
      POSTGRES_DB: postgres
      POSTGRES_PASSWORD: odoo
      POSTGRES_USER: odoo
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - project-internal-network

volumes:
  web-data:
  db-data:

networks:
  project-internal-network:
    driver: bridge
  shared-seq-network:
    external: true
```

#### Maximum Downtime

With the health-check and `auto-heal` settings, the worst-case downtime before the web container is restarted is:

1. Grace period (start_period): 60 s
2. Health‐check failures: 3 × (60 s + 10 s) = 210 s (after the grace period, Docker runs a check every 60 s and allows up to 3 failures with a 10 s timeout each)
3. Auto-heal detection: up to 5 s (default polling interval)
4. Shutdown timeout: up to 10 s (before SIGKILL)

Total worst-case downtime = `210 s + 5 s + 10 s = 225 s` (≈ 3 minutes and 45 seconds).

## CI/CD 

To automate the build and push of Odoo Docker images follow these guides:
 - [Build and Push Docker Image with GitHub Actions](https://victorhachard.github.io/notes/build-push-docker-image-with-github-action)
 - [Build and Push Docker Image with DevOps Pipeline](https://victorhachard.github.io/notes/build-push-docker-image-with-devops-pipeline)
 