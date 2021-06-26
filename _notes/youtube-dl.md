---
title: YouTube-DL
layout: note
draft: false
date: 2020-10-28 10:24:00 +0200
author: Victor Hachard
---

## Commands

```
youtube-dl -o "%(playlist_index)s-%(title)s.%(ext)s" -f bestvideo[height=1080]+bestaudio --merge-output-format mkv PL5nn7Td1DwwlKA63q5swTkSAPp44kaUt7
```

```
--ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output musics\%(title)s.%(ext)s PLOzIeeuepR2T_U-sZ6Hd0p-jOceuwWg_M
```
