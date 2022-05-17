---
layout: note
draft: false
date: 2022-05-17 11:00:00 +0200
author: Victor Hachard
---

## Commands

```sh
foreach ($f in Get-ChildItem "\\TRUENAS\OuranosMedia\Movies\Sort\*.mkv") { mkvpropedit "$f" --edit info -d title --tags all: -d title }
```
