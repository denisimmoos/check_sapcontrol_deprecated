# check_sapcontrol

## Example GetAlertTree:





## Example GetProcessList:

### Step 1: 

<pre>
 ./check_sapcontrol.pl  --hostname hostanme  --sid SID --authfile /etc/icinga2/auth/hostname.auth -F GetProcessList --dump
 
###########################
# $SAPControl->sapcontrol()
###########################
$VAR1 = '1';
$VAR2 = {
          'pid' => '4844',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'igswd.EXE',
          'description' => 'IGS Watchdog',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR3 = '0';
$VAR4 = {
          'pid' => '6988',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'disp+work.EXE',
          'description' => 'Dispatcher',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR5 = '3';
$VAR6 = {
          'pid' => '2736',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'icman',
          'description' => 'ICM',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR7 = '2';
$VAR8 = {
          'pid' => '6456',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'gwrd',
          'description' => 'Gateway',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
</pre>

### Step 2:
<pre>
./check_sapcontrol.pl  --hostname stechsv756 --sid PBV --authfile /etc/icinga2/auth/stechsv756.auth -F GetProcessList --description Gateway
OK - Running
function: GetProcessList
description :  Gateway
dispstatus :  GREEN
elapsedtime :  5
name :  gwrd
pid :  6456
starttime :  2016 06 23 11
textstatus :  Running
</pre>
