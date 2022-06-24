---
layout: note
draft: false
date: 2022-06-09 09:00:00 +0200
author: Victor Hachard
---

## Command

```
sudo smartctl -a /dev/<disk>
```

### SATA drive

```
=== START OF INFORMATION SECTION ===
Device Model:     ST18000NM000J-2TV103
Serial Number:    <removed>
LU WWN Device Id: 5 000c50 0db8f6278
Firmware Version: SNA1
User Capacity:    18,000,207,937,536 bytes [18.0 TB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    7200 rpm
Form Factor:      3.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-4 (minor revision not indicated)
SATA Version is:  SATA 3.3, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Thu Jun  9 07:53:30 2022 CEST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x82) Offline data collection activity
                                        was completed without error.
                                        Auto Offline Data Collection: Enabled.
Self-test execution status:      (   0) The previous self-test routine completed
                                        without error or no self-test has ever
                                        been run.
Total time to complete Offline
data collection:                (  559) seconds.
Offline data collection
capabilities:                    (0x7b) SMART execute Offline immediate.
                                        Auto Offline data collection on/off support.
                                        Suspend Offline collection upon new
                                        command.
                                        Offline surface scan supported.
                                        Self-test supported.
                                        Conveyance Self-test supported.
                                        Selective Self-test supported.
SMART capabilities:            (0x0003) Saves SMART data before entering
                                        power-saving mode.
                                        Supports SMART auto save timer.
Error logging capability:        (0x01) Error logging supported.
                                        General Purpose Logging supported.
Short self-test routine
recommended polling time:        (   1) minutes.
Extended self-test routine
recommended polling time:        (1532) minutes.
Conveyance self-test routine
recommended polling time:        (   2) minutes.
SCT capabilities:              (0x70bd) SCT Status supported.
                                        SCT Error Recovery Control supported.
                                        SCT Feature Control supported.
                                        SCT Data Table supported.

SMART Attributes Data Structure revision number: 10
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   083   064   044    Pre-fail  Always       -       196036912
  3 Spin_Up_Time            0x0003   090   089   000    Pre-fail  Always       -       0
  4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       68
  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       0
  7 Seek_Error_Rate         0x000f   079   060   045    Pre-fail  Always       -       75482958
  9 Power_On_Hours          0x0032   099   099   000    Old_age   Always       -       1139
 10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       68
 18 Unknown_Attribute       0x000b   100   100   050    Pre-fail  Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0022   069   063   000    Old_age   Always       -       31 (Min/Max 26/34)
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       62
193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       1773
194 Temperature_Celsius     0x0022   031   040   000    Old_age   Always       -       31 (0 16 0 0 0)
197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
200 Multi_Zone_Error_Rate   0x0023   100   100   001    Pre-fail  Always       -       0
240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       690 (128 138 0)
241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       29875440714
242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       163532060127

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%      1081         -
# 2  Short offline       Completed without error       00%      1009         -
# 3  Short offline       Completed without error       00%       870         -
# 4  Short offline       Completed without error       00%       725         -
# 5  Short offline       Completed without error       00%       505         -
# 6  Short offline       Completed without error       00%       457         -
# 7  Short offline       Completed without error       00%       412         -
# 8  Short offline       Completed without error       00%       336         -
# 9  Short offline       Completed without error       00%       308         -
#10  Short offline       Completed without error       00%       177         -
#11  Short offline       Completed without error       00%       102         -
#12  Conveyance offline  Completed without error       00%         0         -

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.
```

The 2 big parameters to look at are the read and write `Reallocated_Sector_Ct` and `Current_Pending_Sector`. If both are non-zero this is a strong indication of a disk that is on its way out.

### SAS drive

```
=== START OF INFORMATION SECTION ===
Vendor:               SEAGATE
Product:              ST91000640SS
Revision:             0001
Compliance:           SPC-3
User Capacity:        1,000,204,886,016 bytes [1.00 TB]
Logical block size:   512 bytes
Rotation Rate:        7200 rpm
Form Factor:          2.5 inches
Logical Unit id:      0x5000c50033f374e7
Serial number:        <removed>
Device type:          disk
Transport protocol:   SAS (SPL-3)
Local Time is:        Thu Jun  9 07:47:42 2022 CEST
SMART support is:     Available - device has SMART capability.
SMART support is:     Enabled
Temperature Warning:  Enabled

=== START OF READ SMART DATA SECTION ===
SMART Health Status: OK

Current Drive Temperature:     34 C
Drive Trip Temperature:        68 C

Accumulated power on time, hours:minutes 69502:43
Manufactured in week  of year 20
Specified cycle count over device lifetime:  10000
Accumulated start-stop cycles:  138
Specified load-unload count over device lifetime:  300000
Accumulated load-unload cycles:  1511
Elements in grown defect list: 5

Vendor (Seagate Cache) information
  Blocks sent to initiator = 3540208858
  Blocks received from initiator = 2852120752
  Blocks read from cache and sent to initiator = 1364406119
  Number of read and write commands whose size <= segment size = 1683632186
  Number of read and write commands whose size > segment size = 79251

Vendor (Seagate/Hitachi) factory information
  number of hours powered up = 69502.72
  number of minutes until next internal SMART test = 48

Error counter log:
           Errors Corrected by           Total   Correction     Gigabytes    Total
               ECC          rereads/    errors   algorithm      processed    uncorrected
           fast | delayed   rewrites  corrected  invocations   [10^9 bytes]  errors
read:   777070558        0         0  777070558          0     428423.099           0
write:         0        0        22        22         22      39134.001           0

Non-medium error count:       53

SMART Self-test log
Num  Test              Status                 segment  LifeTime  LBA_first_err [SK ASC ASQ]
     Description                              number   (hours)
# 1  Background short  Completed                   -   65535                 - [-   -    -]
# 2  Background long   Aborted (device reset ?)    -   65535                 - [-   -    -]
# 3  Background long   Completed                   -   65535                 - [-   -    -]
# 4  Background long   Completed                   -   65535                 - [-   -    -]
# 5  Background short  Completed                   -   65535                 - [-   -    -]
# 6  Background short  Completed                   -   65535                 - [-   -    -]
# 7  Background short  Completed                   -   65535                 - [-   -    -]
# 8  Background short  Completed                   -   65535                 - [-   -    -]
# 9  Background long   Completed                   -   65535                 - [-   -    -]
#10  Background short  Completed                   -   65535                 - [-   -    -]
#11  Background short  Completed                   -   65535                 - [-   -    -]
#12  Background short  Completed                   -   65535                 - [-   -    -]
#13  Background short  Completed                   -   65535                 - [-   -    -]
#14  Background short  Completed                   -   65535                 - [-   -    -]
#15  Background short  Completed                   -   65535                 - [-   -    -]
#16  Background long   Completed                   -   65535                 - [-   -    -]
#17  Background short  Completed                   -   65535                 - [-   -    -]
#18  Background short  Completed                   -   65535                 - [-   -    -]
#19  Background short  Completed                   -   65535                 - [-   -    -]
#20  Background short  Completed                   -   65535                 - [-   -    -]

Long (extended) Self-test duration: 12198 seconds [203.3 minutes]
```

The 2 big parameters to look at are the read and write `Total Uncorrected Errors` and `Elements in grown defect list`. If both are non-zero this is a strong indication of a disk that is on its way out.
