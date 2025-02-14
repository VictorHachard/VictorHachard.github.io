---
layout: note
draft: false
date: 2025-01-31 14:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'Linux']
---

This Bash script lists Docker images sorted by creation date (most recent first), grouped by repository. It excludes specific repositories like debian and ubuntu and removes old images from the same repository, keeping only the most recent one. It also prunes unused Docker objects after the cleanup.

```sh
#!/bin/bash

# List images sorted by date of creation (most recent first), grouped by repository only
exclude_repos="debian ubuntu"

docker images --format "{{.Repository}} {{.ID}} {{.CreatedAt}}" | \
    sort -k2,2 -k3,3 | \
    awk '{print $1}' | \
    uniq | \
    while read repository; do
        if [[ -z "$(echo $processed_repos | grep -w $repository)" && -z "$(echo $exclude_repos | grep -w $repository)" ]]; then
            processed_repos+="$repository "
            echo "Processing repository: $repository"

            # Get all image IDs for this repository
            ids=$(docker images --format "{{.ID}} {{.Repository}}" | grep "$repository" | awk '{print $1}')

            # If there are multiple IDs, delete all except the most recent
            if [ $(echo "$ids" | wc -l) -gt 1 ]; then
                echo "$ids" | tail -n +2 | while read id; do
                    echo "Deleting old image: $id for repository $repository"
                    docker rmi "$id"
                done
            fi
        else
            echo "Skipping excluded repository: $repository"
        fi
    done

# Indicate completion of image cleanup
echo "Image cleanup completed."

# Prune unused Docker objects
sudo docker system prune -f

# Indicate completion of Docker object cleanup
echo "Docker object cleanup completed."
```
