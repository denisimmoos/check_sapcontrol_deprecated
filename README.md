# check_sapcontrol

## Example GetAlertTree:

<pre>
./check_sapcontrol.pl -H stechsv254 --authfile /etc/icinga2/auth/stechsv254.auth  --dump
### Step 2: 
<pre>
./check_sapcontrol.pl -H hostname --authfile /etc/icinga2/auth/hostname.auth  --match 'PrivMode Utilisation' --criteria description --critical 60 --warning 20
OK | percent=0%

function: GetAlertTree
criteria: description
ActualValue :  GREEN
AlDescription :
AlTime :
AnalyseToolString :  TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN=X;FNAM=IN_TID-MTSYSID;FVAL=BWD;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTMCNAME;FVAL=stechsv254_BWD_00;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTNUMRANGE;FVAL=010;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTUID;FVAL=0000008990;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTCLASS;FVAL=100;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTINDEX;FVAL=0000000260;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-EXTINDEX;FVAL=0000000150;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=WHICH_TOOL;FVAL=020;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=MTE_NAME;FVAL=\BWD\stechsv254_BWD_00\...\Dialog\PrivMode Utilisation
HighAlertValue :  GREEN
TidString :  MTSYSID=BWD;MTMCNAME=stechsv254_BWD_00;MTNUMRANGE=010;MTUID=0000008990;MTCLASS=100;MTINDEX=0000000260;EXTINDEX=0000000150;
Time :  2016 06 23 17
VisibleLevel :  DEVELOPER
description :  0 %
name :  PrivMode Utilisation
parent :  209
</pre>


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
./check_sapcontrol.pl  --hostname hostname --sid SID  --authfile /etc/icinga2/auth/hostname.auth -F GetProcessList --description Gateway
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
