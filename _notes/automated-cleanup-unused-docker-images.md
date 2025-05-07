---
layout: note
draft: false
date: 2025-01-31 14:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'Linux']
---

## Overview

This Bash script prunes unused Docker images that have no associated containers. It uses the `-a` flag to remove _all_ unused images (not just dangling ones) and `-f` to skip confirmation.

## Script

```sh
#!/bin/bash

# Prune unused Docker images
docker image prune -af --filter "until=24h"

# Indicate completion of image cleanup
echo "Docker image prune complete."
```

## Usage

1. Save the script to `/usr/local/bin/cleanup_unused_docker_images.sh`.
2. Make it executable:
   ```sh
   sudo chmod 700 /usr/local/bin/cleanup_unused_docker_images.sh
   sudo chown root:root /usr/local/bin/cleanup_unused_docker_images.sh
   ```
3. Create a symbolic link in `/etc/cron.daily` to run the script daily:
   ```sh
    sudo ln -s /usr/local/bin/cleanup_unused_docker_images.sh /etc/cron.daily/cleanup_unused_docker_images
    ```
    