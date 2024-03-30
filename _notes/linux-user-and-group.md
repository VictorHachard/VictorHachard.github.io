---
layout: note
draft: false
date: 2019-10-09 7:24:00 +0200
author: Victor Hachard
categories: ['System Administration', 'Linux']
---

## Create a new user

```sh
sudo adduser user_name
sudo passwd 'user_name' password
```

Once a new user created, it’s entry automatically added to the `/etc/passwd` file.

### Delete an user

```sh
sudo userdel user_name
```

### Different home directory

By default ‘useradd‘ command creates a user’s home directory under /home directory with username. Thus, for example, we’ve seen above the default home directory for the user ‘tecmint‘ is ‘/home/tecmint‘.

```sh
useradd -d folder_name user_name
```

### The /etc/passwd file

```sh
tecmint:x:504:504:tecmint:/home/tecmint:/bin/bash
```

-   Username: User login name used to login into system. It should be between 1 to 32 charcters long.
-   Password: User password (or x character) stored in /etc/shadow file in encrypted format.
-   User ID (UID): Every user must have a User ID (UID) User Identification Number. By default UID 0 is reserved for root user and UID’s ranging from 1-99 are reserved for other predefined accounts. Further UID’s ranging from 100-999 are reserved for system accounts and groups.
-   Group ID (GID): The primary Group ID (GID) Group Identification Number stored in /etc/group file.
-   User Info: This field is optional and allow you to define extra information about the user. For example, user full name. This field is filled by ‘finger’ command.
-   Home Directory: The absolute location of user’s home directory.
-   Shell: The absolute location of a user’s shell i.e. /bin/bash.

### Group

There are two types of groups in Linux operating systems:

-   Primary group – When a user creates a file, the file’s group is set to the user’s primary group. Usually, the name of the group is the same as the name of the user. The information about the user’s primary group is stored in the /etc/passwd file.
-   Secondary or supplementary group
-   Useful when you want to grant certain file permissions to a set of users which are members of the group. For example, if you add a specific user to the docker group, the user will inherit the access rights from the group and it will be able to run docker commands.

#### Create/delete group

```sh
sudo groupadd group_name
sudo groupdel group_name
```

#### Add an user to a primary group

```sh
sudo usermod -a -g group_name user_name
```

Always use the -a (append) switch when adding a user to a new group. If you omit the -a switch the user will be removed from any groups not listed after the -G switch.

#### Add/remove an user to a group

```sh
sudo usermod -a -G group_name users_name
sudo usermod -a -G group_name,group_name user_name
```

```sh
sudo gpasswd -d user_name group_name
```

#### Show user group

```sh
id user_name
group user_name
```
