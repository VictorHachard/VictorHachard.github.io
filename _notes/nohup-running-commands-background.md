---
layout: note
title: nohup for Running Commands in the Background
draft: false
date: 2023-09-28 09:49:00 +0200
author: Victor Hachard
categories: ['System Administration']
---

## What is nohup?

`nohup` stands for "no hang up," and it's a command used in Unix-like operating systems to execute other commands and disconnect them from the terminal session. This means that the command will continue running even if you close your terminal or log out of your system.

## Practical Example: Recursively Copying Files

### Scenario

Suppose you have a large directory that you want to copy to another location, and you want the copy process to continue running even if you close your terminal or log out. Here's how you can use `nohup` for this task.

### Step 1: Start the Copy Operation

Begin by running the `cp` command with the `-r` flag to copy a directory and its contents. Replace `source_directory` with the source directory you want to copy and `destination_directory` with the destination directory where you want to copy the files.

```sh
nohup cp -r source_directory destination_directory &
```

### Step 2: Monitor Progress (Optional)

If you want to monitor the progress of the copy operation, you can check the `nohup.out` file in the current directory. This file contains any output or errors from the `cp` command:

```sh
tail -f nohup.out
```

### Step 3: Managing Background Processes

#### Viewing Running Processes

To view a list of background processes running with `nohup`, you can use the `ps` command with options to display the process details. For example:

```sh
ps aux | grep 'nohup'
```

This command will list all processes containing 'nohup' in their command lines.

#### Killing a Process

If you need to terminate a background process created with `nohup`, you can use the `kill` command along with the process ID (PID). First, identify the PID of the process you want to stop using the `ps` command, as shown above. Then, use `kill` with the PID:

```sh
kill PID
```

Replace `PID` with the actual process ID you obtained from the `ps` command.
