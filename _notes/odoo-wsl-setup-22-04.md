---
layout: note
draft: false
date: 2023-06-16 09:49:00 +0200
author: Victor Hachard
---

# Generic configuration

Sets the default WSL version to 2, which provides better performance and more features compared to WSL 1.

```sh
wsl --set-default-version 2
```

Lists the available Linux distributions that can be installed

```sh
wsl --list --online
```

Installs the specified Ubuntu 22.04 distribution

```sh
wsl --install -d Ubuntu-22.04
```

# Basic WSL configuration

Modify the WSL configuration file

```sh
sudo nano /etc/wsl.conf
```

Opens the `/etc/wsl.conf` file in the `nano` text editor. The subsequent lines configure specific settings in the file. The `[user]` section sets the default user to "ubuntu", and the `[boot]` section enables systemd initialization.

```sh
[user]
default = ubuntu

[boot]
systemd=true
```

# Basic Ubuntu configuration

## Sudoers

Modify the `sudo` configuration to allow the user `ubuntu` to run commands with `sudo` without entering a password.

```sh
sudo nano /etc/sudoers.d/ubuntu
```

Add the following line:

```sh
ubuntu ALL=(ALL) NOPASSWD:ALL
```

## Installation

Installs the `zip` and `unzip` utilities:

```sh
sudo apt-get install zip unzip -y
```

## Git settings

Installs the `git`:

```sh
sudo apt-get install git
```

configure Git settings. The first command disables automatic line ending conversion in Git, which can be useful when working with cross-platform projects. The second and third commands set the global Git username and email address to be used for commits.

```sh
git config --global core.autocrlf false
git config --global user.name "Ubuntu"
git config --global user.email ubuntu@users.noreply.github.com
```

# Backup

Exports a WSL distribution named "Ubuntu" to a TAR file called "ubuntu2204base.tar". It creates a backup or snapshot of the Ubuntu distribution that can be imported later.

```sh
wsl --export Ubuntu ubuntu2204base.tar
```

# Import

## Windows

Imports a new WSL distribution from the "ubuntu2204base.tar" file. It creates a new WSL distribution named "ubuntu-22-04-odoo-x" based on the exported Ubuntu distribution. 


```sh
wsl --import ubuntu-22-04-odoo-x .\ubuntu-22-04-odoo-x ubuntu2204base.tar
```

Sets the WSL version for the specified distribution "ubuntu-22-04-odoo-1x" to version 2.

```sh
wsl --set-version ubuntu-22-04-odoo-1x 2
```

Starts the WSL session with the "ubuntu-22-04-odoo-1x" distribution.

```sh
wsl -d ubuntu-22-04-odoo-1x
```

## WSL

Updates the package lists and upgrade packages.

```sh
sudo apt update -y && sudo apt upgrade -q -y
```

Download and install the `wkhtmltopdf` package, which is a tool used to convert HTML to PDF. It fetches a specific version of the package from a GitHub release and installs it using `apt-get`. The final command checks the version of `wkhtmltopdf` to verify the installation.

```sh
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt-get install ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb -y
wkhtmltopdf --version
```

Installs the PostgreSQL database server and additional contributed modules.

```sh
sudo apt install postgresql postgresql-contrib -y
```

Opens the PostgreSQL host-based authentication configuration file in the `nano` text editor.

```sh
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

Replace this line:
```sh
local   all             all                                peer
```

By:

```sh
local   all             all                                md5
```

Enables the PostgreSQL service to start automatically on system boot.

```sh
sudo systemctl enable postgresql.service
```

### Odoo 15/16

Install various dependencies and development tools required for Python and Odoo development. It includes packages like `build-essential`, `python3.10`, `python3-pip`, and many others.

```sh
sudo apt install build-essential python3.10 -y
sudo apt install python3-pip python3-dev python3-venv python3-wheel libxml2-dev libpq-dev libjpeg8-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libblas-dev libatlas-base-dev -y
```

### Odoo 13

Install various dependencies and development tools required for Python and Odoo development. It includes packages like `build-essential`, `python3.6`, `python3-pip`, and many others.

```sh
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install build-essential python3.6 python3.6-full python3.6-distutils python3.6-dev python3-pip python3-dev python3-venv python3-wheel libxml2-dev libpq-dev libjpeg8-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libblas-dev libatlas-base-dev -y
```

Install the node-less package, which provides the Less CSS preprocessor for Node.js. It's used by Odoo for CSS compilation.

Install Node.js and npm (Node Package Manager) and then use npm to install specific versions of the less package and the less-plugin-clean-css package. They are also used by Odoo for CSS compilation.

```sh
sudo apt-get install node-less -y
sudo apt-get install nodejs npm -y
sudo npm install -g less@3.10.3 less-plugin-clean-css
```

### Odoo 11

Install various dependencies and development tools required for Python and Odoo development. It includes packages like `build-essential`, `python3.7`, `python3-pip`, and many others.


```sh
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install build-essential python3.7 python3.7-full python3.7-distutils python3.7-dev python3-pip python3-dev python3-venv python3-wheel libxml2-dev libpq-dev libjpeg8-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libblas-dev libatlas-base-dev -y
```

Install the node-less package, which provides the Less CSS preprocessor for Node.js. It's used by Odoo for CSS compilation.

Install Node.js and npm (Node Package Manager) and then use npm to install specific versions of the less package and the less-plugin-clean-css package. They are also used by Odoo for CSS compilation.

```sh
sudo apt-get install node-less -y
sudo apt-get install nodejs npm -y
sudo npm install -g less@3.10.3 less-plugin-clean-css
```

## Add a project

### PostgreSQL

Switches to the postgres user with root privileges:

```sh
sudo -i -u postgres
```

Start the PostgreSQL command-line tool (psql):

```sh
psql
```

Execute SQL command to create a database users: odoo_project_x with the password 'odoo' and the ability to create databases.

```sh
CREATE USER odoo_project_x WITH PASSWORD 'odoo' CREATEDB;
```

### Dependency

Activate a virtual environment, install Python packages specified in the requirements.txt file located at the given path, and then deactivate the virtual environment.

```sh
source <name>-odoo-1x/bin/activate
<name>-odoo-1x/bin/pip install -r /home/<name>-odoo-1x/src/requirements.txt
deactivate
```
