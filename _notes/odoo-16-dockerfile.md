---
layout: note
title: Docker Setup for Long-Term Odoo 16 Deployment
draft: true
date: 2025-02-06 14:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'Odoo', 'System Administration']
---

🎯 **TODO:** Update this guide when Odoo becomes compatible with Python 3.13 or when Python 3.12 will fully be compatible.

⚠️ **Warning:** The latest Odoo version does not yet fully support Python 3.12. For now, a Dockerfile is available with **Ubuntu 24.04 (Noble) and Python 3.11** to ensure compatibility.

⚠️ **Warning:** This setup has been tested as of early 2025. Future Ubuntu updates may require modifications to maintain compatibility.

## Purpose

Odoo 16, originally released in 2022 and with support ending in October 2025. It is compatible with Python versions 3.7 to 3.12 but **does not support Python 3.13 or later**. To ensure compatibility, we must use **Python 3.12**, which can be installed via the **[deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)**.

⚠️ **Warning:** Python 3.12 will receive official security updates and maintenance until October 2028.

⚠️ **Disclaimer:** PPAs are community-maintained and may not always receive timely updates, including security patches. Using deprecated libraries can introduce vulnerabilities and compatibility issues. Deploying this setup in production or security-sensitive environments is at your own risk.

This setup includes a customized **Dockerfile** optimized for running Odoo 15 on modern systems. Key modifications include:

- **Ubuntu 24.04 (Noble)** as the base image.
- Installation of **Python 3.12** via the **deadsnakes PPA**.
- Use of **virtual environments** to prevent conflicts with system packages.

## Prerequisites

### Odoo version

Odoo 16.0 needs to be updated with the latest nightly build because Python 3.12 was not supported when Odoo 16.0 was initially released. You can find the Odoo version in the `release.py` file within the Odoo source code.

### Directory Structure

Ensure your project follows this directory structure:

```plaintext
src/
├── app_addons/
├── custom_addons/
├── odoo/
├── Dockerfile 🐳
├── entrypoint.sh 🐳
├── odoo.conf
├── requirements.txt
└── wait-for-psql.py 🐳
```  

`wait-for-psql.py` and `entrypoint.sh` are available from the [Odoo Docker repository](https://github.com/odoo/docker/blob/master/). Use the **18.0 version** of both scripts:
  - `wait-for-psql.py` **has not changed** between Odoo 16.0 and 18.0, so it remains fully compatible.  
  - `entrypoint.sh` **has not changed** between Odoo 16.0 and 18.0, so it remains fully compatible.

For reference, the scripts from Odoo 16.0 can be found in the [Odoo Docker 16.0 repository](https://github.com/odoo/docker/tree/master/16.0).

## Dockerfile (Noble)

⚠️ **Warning:** Ubuntu 24.04 Noble will receive official security updates and maintenance until April 2029.

```dockerfile
FROM ubuntu:noble
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for PostgreSQL and general locale data
ENV LANG=C.UTF-8

# Install system dependencies and Python 3.12
# Removed fonts-noto-cjk (add if needed for Chinese, Japanese, Korean support)
# Removed npm (add if needed for RTL language support)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        dirmngr \
        gnupg \
        libssl-dev libpq-dev \
        libldap2-dev libsasl2-dev \
        python3 python3-dev python3-pip python3-venv python3-wheel \
        xz-utils \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl && \
    if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  ;; \
    "arm64")  WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc  ;; \
    "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install PostgreSQL client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
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
# Add if needed for RTL language support
# RUN npm install -g rtlcss

# Create Odoo system user and group
RUN groupadd -r odoo && useradd -r -g odoo -m -d /home/odoo -s /bin/bash odoo

# Set Odoo environment variables
ENV ODOO_HOME=/opt/odoo
ENV VENV_PATH=$ODOO_HOME/venv
ENV PATH="$VENV_PATH/bin:$PATH"
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

# Copy entrypoint script and wait-for-psql script
COPY entrypoint.sh /entrypoint.sh
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chmod +x /entrypoint.sh
RUN chmod +x /usr/local/bin/wait-for-psql.py

# Fix line endings in scripts (Windows compatibility)
RUN sed -i 's/\r$//' /usr/bin/odoo /etc/odoo/odoo.conf /usr/local/bin/wait-for-psql.py /entrypoint.sh /etc/systemd/system/odoo.service

# Create odoo directory and set permissions
RUN mkdir -p /var/lib/odoo && chown -R odoo /var/lib/odoo

# Create and activate Python virtual environment (useful to avoid conflicts with system packages)
RUN python3 -m venv $ODOO_HOME/venv && \
    source $VENV_PATH/bin/activate

# Install Odoo dependencies
COPY requirements.txt $ODOO_HOME/
RUN $VENV_PATH/bin/pip install --no-cache-dir --upgrade pip && \
    $VENV_PATH/bin/pip install --no-cache-dir -r $ODOO_HOME/requirements.txt

# Copy Odoo source files and custom addons
COPY --chown=odoo:odoo odoo $ODOO_HOME/odoo
COPY --chown=odoo:odoo app_addons $ODOO_HOME/app_addons
COPY --chown=odoo:odoo custom_addons $ODOO_HOME/custom_addons

# Expose volumes and ports (8069: Odoo, 8071: XML-RPC, 8072: longpolling)
VOLUME ["/var/lib/odoo"]
EXPOSE 8069 8071 8072

# Set default environment variables
ENV ODOO_RC=/etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
```

## Dockerfile (Noble - Python 3.11)

⚠️ **Warning:** Ubuntu 24.04 Noble will receive official security updates and maintenance until April 2029.

⚠️ **Warning:** Python 3.11 will receive official security updates and maintenance until October 2027.

Replace the system dependencies with the following:

```dockerfile
# Install prerequisites for adding PPA
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        gpg-agent \
        gnupg \
        dirmngr \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA
RUN add-apt-repository ppa:deadsnakes/ppa

# Install system dependencies and Python 3.11
# Removed fonts-noto-cjk (add if needed for Chinese, Japanese, Korean support)
# Removed npm (add if needed for RTL language support)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev libpq-dev \
        libldap2-dev libsasl2-dev \
        xz-utils \
        python3.11 python3.11-distutils python3.11-venv python3.11-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default Python version
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    python3.11 -m ensurepip && \
    python3.11 -m pip install --upgrade pip

# Verify Python 3.11 installation and pip version
RUN python --version | grep "3.11" && pip --version
```
