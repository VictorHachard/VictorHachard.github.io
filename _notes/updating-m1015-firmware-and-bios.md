---
layout: note
draft: false
date: 2020-10-11 47:40:00 +0200
author: Victor Hachard
---

## Updating SuperMicro M1015 Firmware and BIOS

To update the firmware and BIOS of your SuperMicro M1015 RAID controller, follow the steps below:

1. Download the required files:
   - [M1015.zip]({{site.baseurl}}/res/m1015/M1015.zip): This archive contains the necessary files for the update process.

2. Boot into the UEFI built-in shell:
   - Restart your system and enter the SuperMicro BIOS by pressing the appropriate key during the boot process (e.g., Del, F11 or F2).
   - In the BIOS settings, navigate to the "Boot" tab and change the boot order to prioritize the UEFI built-in shell.
   - Save the changes and exit the BIOS.

3. Access the UEFI built-in shell:
   - After the system restarts, you will be presented with the UEFI built-in shell.
   - In the shell, enter the following commands to navigate to the appropriate drive:
     ```
     fs0:
     ```

4. Flash the firmware:
   - To erase the current firmware, use the following command:
     ```
     sas2flash.efi -o -e 6
     ```
   - To update the firmware with the downloaded file, use the following command:
     ```
     sas2flash.efi -o -f <firmware>.bin
     ```
     Replace `<firmware>` with the actual file name `2118it.bin` obtained from the 9211-8i_Package_P20_IR_IT_Firmware_BIOS_for_MSDOS_Windows archive.

5. Flash the BIOS:
   - To update the BIOS ROM with the downloaded file, use the following command:
     ```
     sas2flash.efi -o -b <biosrom>.rom
     ```
     Replace `<biosrom>` with the actual file name `mptsas2.rom` obtained from the 9211-8i_Package_P20_IR_IT_Firmware_BIOS_for_MSDOS_Windows archive.
   - To update the UEFI BSD with the downloaded file, use the following command:
     ```
     sas2flash.efi -o -b <uefibsd>.rom
     ```
     Replace `<uefibsd>` with the actual file name `x64sas2.rom` obtained from the UEFI_BSD_P20 archive.

6. Set the SAS serial ID:
   - To configure the SAS Serial ID, use the following command:
     ```
     sas2flash.efi -o -sasadd 5XXXXXXXXXXXX
     ```
     Replace `5XXXXXXXXXXXX` with the actual SAS Serial ID of your M1015 controller.

Make sure to follow the steps carefully and double-check the file names and commands to ensure a successful update process.