---
layout: note
title: Odoo & Docker
draft: false
date: 202-11-14 14:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

## Server Setup


### Install Docker

Docker is a platform for developing, shipping, and running applications in containers. You can install Docker on your server using Snap or apt.

#### Install Docker with Snap

Docker can be installed using Snap during the Ubuntu setup or manually afterward.

**Important:** To prevent unexpected interruptions due to automatic updates, configure Snap to control Docker updates.

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

Recommended dashboards include:
- [Docker monitoring](https://grafana.com/grafana/dashboards/193): 193
- [Node Exporter Full](https://grafana.com/grafana/dashboards/1860): 1860
