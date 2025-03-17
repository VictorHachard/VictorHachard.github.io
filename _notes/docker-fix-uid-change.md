---
layout: note
title: Docker Fix UID Change
draft: false
date: 2025-02-10 17:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'System Administration']
---

Problem:

After updating your Docker image, the user’s UID changed, causing permission errors on the mounted directories.

Solution:

To fix this issue, you need to change the permissions of the directory to the new UID.

First, get the container ID by running the following command:

```bash
docker ps
```

Then, exec into the container with the following command:

```bash
docker exec -it --user root container_id /bin/bash
```

Then, run the following command to change the UID of the directory:

```bash
chown -R user_id:group_id /path/to/directory
```

Finally, exit the container and restart it:

```bash
exit
docker restart container_id
```
