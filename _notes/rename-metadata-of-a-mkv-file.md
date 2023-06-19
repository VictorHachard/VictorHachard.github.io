---
layout: note
draft: false
date: 2022-05-17 11:00:00 +0200
author: Victor Hachard
---

## Removing Title Tags from MKV Files Using PowerShell

To remove the title tags from multiple MKV files using PowerShell, follow these steps:

1. Open PowerShell:
   - Press `Windows Key + X` on your keyboard to open the Power User Menu.
   - Select "Windows PowerShell" or "Windows PowerShell (Admin)" from the menu.

2. Navigate to the directory containing the MKV files:
   - Use the `cd` command to change to the directory where your MKV files are located. For example:
     ```sh
     cd "\\TRUENAS\OuranosMedia\Movies\Sort\"
     ```

3. Run the PowerShell script:
   - Copy and paste the following command into the PowerShell window:
     ```powershell
     foreach ($f in Get-ChildItem "*.mkv") { mkvpropedit "$f" --edit info -d title --tags all: -d title }
     ```
     This script uses a `foreach` loop to iterate over each MKV file in the directory. The `mkvpropedit` command is used to remove the title tags from each file.

Please note that this script assumes you have the `mkvpropedit` utility installed and available in your system's PATH. Ensure that you have the necessary permissions to modify the files in the specified directory.
