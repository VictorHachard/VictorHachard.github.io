---
layout: note
draft: false
date: 2023-06-16 10:11:00 +0200
author: Victor Hachard
---

Exclude the following directories from real-time scanning, source: [intellij support](https://intellij-support.jetbrains.com/hc/en-us/articles/360006298560-Antivirus-Impact-on-Build-Speed#:~:text=Click%20on%20%E2%80%9CVirus%20and%20threat,menu%2C%20and%20select%20the%20folder.):

```sh
%APPDATA%\JetBrains
%LOCALAPPDATA%\JetBrains\
```
