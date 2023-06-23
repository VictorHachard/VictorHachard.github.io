---
layout: note
title: Update Metadata of a MKV File
draft: false
date: 2022-05-17 11:00:00 +0200
author: Victor Hachard
---

## Track Update from MKV Files Using PowerShell

### Reorder Track

To reorder the tracks from multiple MKV files using PowerShell:

```powershell
for %%a in ("*.mkv") do mkvpropedit "%%a" ^
--edit track:a1 --set flag-default=0 --set flag-forced=0 ^
--edit track:a2 --set flag-default=1 --set flag-forced=0 ^
--edit track:s1 --set flag-default=0 --set flag-forced=0 ^
--edit track:s2 --set flag-default=1 --set flag-forced=0
```

This script use the `mkvpropedit` utility installed and available in your system's PATH.

### Update Track

To update the tracks from multiple MKV files using PowerShell:

```powershell
mkdir output
for %%a in ("*.mkv") do mkvmerge.exe -o "output\%%~na.mkv" ^
--audio-tracks 2 ^
--subtitle-tracks 4 ^
"%%a"
```

This script use the `mkvmerge` utility installed and available in your system's PATH.

## Removing Title Tags from MKV Files Using PowerShell

To remove the title tags from multiple MKV files using PowerShell:

```powershell
foreach ($f in Get-ChildItem "*.mkv") { mkvpropedit "$f" --edit info -d title --tags all: -d title }
```

This script use the `mkvpropedit` utility installed and available in your system's PATH.
