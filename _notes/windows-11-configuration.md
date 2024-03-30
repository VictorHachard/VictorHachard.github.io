---
layout: note
draft: false
date: 2024-03-30 09:40:00 +0200
author: Victor Hachard
categories: ['System Administration', 'Windows']
---

## 1 Restore old Right-click Context menu in Windows 11

- Press `Win + X`, selecting `Windows Terminal (Admin)`, and clicking `Yes` in the User Account Control dialog.
- Run the following command to restore the old right-click context menu:
```sh
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

If you want to restore the new context menu, run the following command:
```sh
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
```

## 2 Remove password from Windows 11

- Open the Registry Editor by pressing `Win + R`, typing `regedit`, and pressing `Enter`.
- Navigate to the following key:
```sh
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device
```
- Set the value of `DevicePasswordLessBuildVersion` to `0` to remove the password requirement.
- Open the Registry Editor by pressing `Win + R`, typing `netplwiz`, and pressing `Enter`.
- Uncheck `Users must enter a user name and password to use this computer` and click `Apply`.
- Then reset the password for the user account.

If you want to re-enable the password requirement, check `Users must enter a user name and password to use this computer` in the `netplwiz` dialog.
Optionally, you can set the value of `DevicePasswordLessBuildVersion` to `2` or `1` in the Registry Editor.
