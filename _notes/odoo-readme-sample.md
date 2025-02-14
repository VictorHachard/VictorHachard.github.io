---
layout: note
draft: false
active: false
date: 2024-07-15 11:36:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

# Odoo `<odoo_version>` - `<project_name>`

## Installation

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Important information

### Requirements

- [Odoo `<odoo_version>` - odoo_20240122](https://nightly.odoo.com/`<odoo_version>`.0/nightly/src/)
- [Python 3.10](https://www.python.org/downloads/release/python-310/)
- [PostgresSQL 14](https://www.postgresql.org/download/)
- [wkhtmltopdf 0.12.6.1 (with patched qt) / Windows](https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1/wkhtmltox-0.12.6-1.msvc2015-win64.exe)
- [wkhtmltopdf 0.12.6.1-2 (with patched qt) / Ubuntu](https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb)
- [build-tools from Microsoft (C++) / Windows](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
 
*When installing wkhtmltopdf on Windows, make sure to add an environment variable pointing to the "bin" folder.*
*When installing build-tools on Windows, make sure to install tools for C++ (SDK need to be checked).*

### Setup

#### Clone the repository

In GitHub Desktop, select "Clone Repository," paste the repository URL in the "URL" field, specify your local directory, and click "Clone" to start the cloning process.

#### Database configuration

Create a new Login Role with these parameters:

-   Name: ``<project_name>`_odoo_`<odoo_version>``
-   Password: `odoo`
-   Privileges: Can login, Create databases, Inherit right from the parent roles.

```sql
CREATE USER `<project_name>`_odoo_`<odoo_version>` WITH PASSWORD 'odoo' CREATEDB;
```

#### Odoo configuration

Create a configuration file name 'odoo.conf' in a configuration folder and then copy and paste this following configuration.

```
[options]
admin_passwd = odoo
addons_path = PATH_TO_ADDONS,PATH_TO_OTHER_ADDONS

db_host = 127.0.0.1
db_user = `<project_name>`_odoo_`<odoo_version>`
db_password = odoo

db_port = 5432
http_port = 8069

limit_time_cpu = 600
limit_time_real = 1200
max_cron_threads = 1
workers = 0
db_maxconn = 200
```

#### Pycharm project setting

In the Pycharm settings, open the project settings, delete the existing root content, and replace it with a new root content directory such as ``<project_name>`/src`.

#### Pycharm interpreter setting

Create a virtual environment (venv) with Pycharm.

Upgrade pip to the latest version.
```bash
python -m pip install --upgrade pip
```

Install all the dependencies using the 'requirements.txt' located in the root folder (do not install the dependencies using Pycharm, Pycharm does not take into account the conditions).

```bash
pip install -r src\requirements.txt
```

#### pydevd-odoo

PyDev.Debugger is the Python debugger used in PyDev, PyCharm, VSCode. This plugin aims to make the debugger works better for Odoo.

```bash
pip install pydevd-odoo
```

#### Pycharm run configuration

Use the Python or the Odoo preset.

- Script path: `PATH_TO\odoo-bin`
- Script parameters: `-c odoo.conf`

You can add more parameters (examples):
- the `--dev xml` allows you not to have to reload the module when editing xml files
- the `-d <database>` allows you to specify the database name
- the `-u <module list>` allows you to specify modules to update on startup
- the `-i <module list>` allows you to specify modules to install on startup

## Migration

If you update the code to a new version read this first. We added a few new features to the code that are hardcoded in the code.

### Not Inherited in Code

Every modification to the source code is tagged with the comment `# TODO: inherit` or `// TODO: inherit`

The list of files updated for this modification:

- ``
