---
layout: note
title: entrypoint.sh for Odoo Docker
draft: false
active: false
date: 2025-02-06 14:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'Odoo']
---

## Purpose

The `entrypoint.sh` script is a component of the Odoo Docker setup. It is responsible for initializing the Odoo server, managing database connections, and handling signals for graceful shutdowns. This script is executed every time the Docker container starts.

It is based on a fork of the [Odoo Docker repository](https://github.com/odoo/docker/blob/master/18.0/entrypoint.sh).

## Docker Compose Example

The `entrypoint.sh` script allows you to configure the Odoo server using environment variables. Below is an example of how to set up Odoo with Docker Compose by defining parameters directly in the environment:

```yaml
services:
  web:
    environment:
      PROXY_MODE: True
      LIST_DB: False
      WORKERS: 2
      MAX_CRON_THREADS: 0
      ADMIN_PASSWD: odoo
```

Configuration options:

| Variable            | Description                                   | Default Value     |
|---------------------|-----------------------------------------------|-------------------|
| HOST                | PostgreSQL database host                      | db                |
| PORT                | PostgreSQL database port                      | 5432              |
| USER                | PostgreSQL database user                      | odoo              |
| PASSWORD            | PostgreSQL database password                  | odoo              |
| WORKERS             | Number of worker processes                    | 0                 |
| MAX_CRON_THREADS    | Maximum number of cron threads                | 1                 |
| LIMIT_MEMORY_SOFT   | Soft memory limit                             | 2147483648        |
| LIMIT_MEMORY_HARD   | Hard memory limit                             | 2684354560        |
| LIMIT_TIME_CPU      | CPU time limit (seconds)                      | 60                |
| LIMIT_TIME_REAL     | Execution time limit (seconds)                | 120               |
| LIMIT_REQUEST       | Maximum number of requests                    | 65536             |
| LIST_DB             | Allow database listing                        | True              |
| PROXY_MODE          | Enable proxy mode                             | False             |
| ADMIN_PASSWD        | Odoo administrator password                   | N/A               |
| SERVER_WIDE_MODULES | List of globally available server modules     | N/A               |

### Custom Configuration File

Alternatively, you can configure Odoo using a custom configuration file by setting the `OVERRIDE_CONF_FILE` environment variable. This approach provides greater flexibility for defining Odoo settings.

💡 **Note:** When using a custom configuration file, ensure that the **`addons_path`** and **`data_dir`** are properly defined. You can check the `entrypoint.sh` script for default values.

```yaml
services:
  web:
    environment:
      OVERRIDE_CONF_FILE: |
        [options]
        addons_path = /opt/odoo/odoo/addons,/opt/odoo/app_addons,/opt/odoo/custom_addons
        data_dir = /var/lib/odoo
        proxy_mode = True
        list_db = False
        workers = 2
        max_cron_threads = 0
        admin_passwd = odoo
```

## entrypoint.sh Script

💡 **Note:** If an Odoo parameter is missing from the script, you can add it by referring to the Odoo source code. Check the `configmanager` class in `tools/config.py`. The second argument in the `add_option` method will guide you on how to correctly integrate it into the launch process.

```bash
#!/bin/bash
set -e

# Check if there is no configuration conflict
if [ -n "${OVERRIDE_CONF_FILE}" ]; then
  disallowed_vars=(
    "WORKERS"
    "MAX_CRON_THREADS"
    "LIMIT_MEMORY_SOFT"
    "LIMIT_MEMORY_HARD"
    "LIMIT_TIME_CPU"
    "LIMIT_TIME_REAL"
    "LIMIT_REQUEST"
    "LIST_DB"
    "PROXY_MODE"
    "UNACCENT"
    "ADMIN_PASSWD"
    "SERVER_WIDE_MODULES"
  )

  for var in "${disallowed_vars[@]}"; do
    if [ -n "${!var}" ]; then
      echo "Error: The following environment variables cannot be set when using a custom Odoo configuration:"
      printf '       %s\n' "${disallowed_vars[@]}"
      exit 1
    fi
  done
fi

# Check if the password file is set and read the password from it
if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# Set the default values for the database host, port, user and password
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

# Set Odoo configuration parameters
: ${WORKERS:=0}
: ${MAX_CRON_THREADS:=1}
: ${LIMIT_MEMORY_SOFT:=2147483648}
: ${LIMIT_MEMORY_HARD:=2684354560}
: ${LIMIT_TIME_CPU:=60}
: ${LIMIT_TIME_REAL:=120}
: ${LIMIT_REQUEST:=65536}
: ${LIST_DB:=True}
: ${PROXY_MODE:=False}
: ${UNACCENT:=False}

# Apply custom Odoo configuration if provided
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

# Set the databse configuration parameters
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

# Set Odoo configuration parameters if not using a custom configuration
ODOO_ARGS=("${DB_ARGS[@]}")

if [ -z "${OVERRIDE_CONF_FILE}" ]; then
    # Update the Odoo configuration file
    if [ -n "${ADMIN_PASSWD}" ]; then
        if grep -q -E "^\s*admin_passwd\s*=" "$ODOO_RC" ; then
            sed -i "s/^\s*admin_passwd\s*=.*/admin_passwd = ${ADMIN_PASSWD}/" "$ODOO_RC"
        else
            echo "admin_passwd = ${ADMIN_PASSWD}" >> "$ODOO_RC"
        fi
    else
        sed -i "/^\s*admin_passwd\s*=/d" "$ODOO_RC"
    fi
    if [ -n "${SERVER_WIDE_MODULES}" ]; then
        if grep -q -E "^\s*server_wide_modules\s*=" "$ODOO_RC" ; then
            sed -i "s/^\s*server_wide_modules\s*=.*/server_wide_modules = ${SERVER_WIDE_MODULES}/" "$ODOO_RC"
        else
            echo "server_wide_modules = ${SERVER_WIDE_MODULES}" >> "$ODOO_RC"
        fi
    else
        sed -i "/^\s*server_wide_modules\s*=/d" "$ODOO_RC"
    fi

    # Update the Odoo configuration parameters
    ODOO_ARGS+=("--workers=${WORKERS}")
    ODOO_ARGS+=("--max-cron-threads=${MAX_CRON_THREADS}")
    ODOO_ARGS+=("--limit-memory-soft=${LIMIT_MEMORY_SOFT}")
    ODOO_ARGS+=("--limit-memory-hard=${LIMIT_MEMORY_HARD}")
    ODOO_ARGS+=("--limit-time-cpu=${LIMIT_TIME_CPU}")
    ODOO_ARGS+=("--limit-time-real=${LIMIT_TIME_REAL}")
    ODOO_ARGS+=("--limit-request=${LIMIT_REQUEST}")
    if [ -n "${LIST_DB}" ] && { [ "${LIST_DB}" = "False" ] || [ "${LIST_DB}" = "false" ] || [ "${LIST_DB}" = false ]; }; then
        ODOO_ARGS+=("--no-database-list")
    fi
    if [ -n "${PROXY_MODE}" ] && { [ "${PROXY_MODE}" = "True" ] || [ "${PROXY_MODE}" = "true" ] || [ "${PROXY_MODE}" = true ]; }; then
        ODOO_ARGS+=("--proxy-mode")
    fi
    if [ -n "${UNACCENT}" ] && { [ "${UNACCENT}" = "True" ] || [ "${UNACCENT}" = "true" ] || [ "${UNACCENT}" = true ]; }; then
        ODOO_ARGS+=("--unaccent")
    fi
fi

if [ -n "${UPDATE}" ]; then
    ODOO_ARGS+=("--update=${UPDATE}")
fi

# Launch Odoo server
case "$1" in
    -- | odoo)
        shift
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        echo "Executing: odoo $@ ${ODOO_ARGS[@]}"
        exec odoo "$@" "${ODOO_ARGS[@]}"
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        echo "Executing: odoo $@ ${ODOO_ARGS[@]}"
        exec odoo "$@" "${ODOO_ARGS[@]}"
        ;;
esac

exit 1
```
