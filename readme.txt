





edb360 v1712 (2017-04-16) by Carlos Sierra
~~~~~~~~~~~~
edb360 is a "free to use" tool to perform an initial assessment of an Oracle database. 

eDB360 works on Oracle 10g to 12c databases. 

eDB360 works on Linus and UNIX systems. 

For Windows systems you may want to install first UNIX Utilities (UnxUtils) and a zip 
program, else a few OS commands may not properly work. Besides that it works on Windows.

edb360 installs nothing on the database. 

For better results execute connected as DBA, or as a user with access to data dictionary.

edb360 may take up to 24 hours to execute if your AWR data is not properly partitioned or
purged. 

Before executing edb360 please perform a pre-check of ASH on AWR by reviewing output of 
included script edb360-master/sql/awr_ash_pre_check.sql.

Best time to execute edb360 is overnight or over a weekend.

Output ZIP file can be large (over 100 MBs), so you may want to place and execute edb360
on a system directory with at least 1 GB of free space. 

****************************************************************************************

Steps
~~~~~
1. Unzip edb360-master.zip, navigate to the root edb360-master directory, and connect as 
   DBA, or any user with access to the Data Dictionary:

   $ unzip edb360-master.zip
   $ cd edb360-master
   $ sqlplus <dba_user>/<dba_pwd>

2. Execute sql/awr_ash_pre_check.sql and review output, specially last page. Then decide
   if continuing with edb360 (step 3 below) or remediate first findings reported.

3. Execute edb360.sql passing two parameters either inline or when asked.

   Parameter 1: Oracle License Pack (required)
   
   Indicate if your database is licensed for the Oracle Tuning Pack, 
   the Diagnostics Pack or None [ T | D | N ]. Example below specifies Tuning Pack. If 
   licensed for both Tuning and Diagnostics pass then T.
   
   Parameter 2: Custom edb360 configuration filename (optional)

   note: This parameter is for advanced users, thus a NULL value is common. 2nd param
         can also accept a column, range of columns, section or range of sections;
         for example: 7, 6-7, 7a, 7a-7b, 1b-2b

   Execution samples:

   SQL> @edb360.sql T NULL          normal execution when Tuning pack is licensed
   
   SQL> @edb360.sql T custom.sql    passing a custom configuration file changing value
                                    of some configuration parameters

   SQL> @edb360.sql T 7a            generate only section 7a (AWR, ADDM and ASH reports)
   
4. Unzip output edb360_<NNNNNN>_<NNNNNN>_YYYYMMDD_HH24MI.zip into a directory on your PC

5. Open and review main html file 00001_edb360_<NNNNNN>_index.html using a browser

****************************************************************************************

Notes
~~~~~
1. If you need to execute edb360 against all databases in host use then run_db360.sh:

   $ unzip edb360-master.zip
   $ cd edb360-master
   $ sh run_edb360.sh

   note: this method requires Oracle Tuning pack license in all databases in such host.

2. If you need to generate edb360 for a range of dates other than last 31 days; or change
   default "working hours" between 7:30AM and 7:30PM; or suppress an output format such as
   text or csv; set a custom configuration file based on edb360_00_config.sql.
   
   note: eDB360 defaults to 31 days if your AWR retention is larger than 31 days.
   
3. How to find the license pack option that you have installed?

   select value from v$parameter where name = 'control_management_pack_access';

4. How to find how many days are kept in the AWR repository?

   select retention from DBA_HIST_WR_CONTROL;

5. edb360 needs the following grants when executed as user xxx

   grant select any dictionary to xxx;
   grant advisor to xxx;
   grant execute on dbms_workload_repository to xxx;
   grant execute on dbms_lock to xxx;

****************************************************************************************

Troubleshooting
~~~~~~~~~~~~~~~
edb360 takes up to 24 hours to execute on a large database. On smaller ones or on Exadata
it may take a few hours or less. In rare cases it may require even more than 24 hrs.

If you think edb360 takes too long on your database, the first suspect is usually the 
state of AWR tables. Use sql/awr_ash_pre_check.sql to validate AWR state.

Troubleshooting steps below are for improving performance of edb360 based on known issues.

Steps:

1. Refer to https://carlos-sierra.net/2016/11/23/edb360-takes-long-to-execute/

2. If edb360 version (first line on this readme) is older than 1 month, download and use
   latest version: https://github.com/carlos-sierra/edb360/archive/master.zip

3. If after going through steps above, edb360 still takes longer than a few hours, feel 
   free to email author carlos.sierra.usa@gmail.com and provide files from step 1.

****************************************************************************************
   
    edb360 - Enkitec's Oracle Database 360-degree View
    Copyright (C) 2017  Carlos Sierra

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************************

edb360 sections 

1a. Database Configuration
1b. Security
1c. Auditing
1d. Memory
1e. Resources (as per AWR and MEM)
1f. Resources (as per Statspack)

2a. Database Administration
2b. Storage
2c. Automatic Storage Management (ASM)
2d. Backup and Recovery

3a. Database Resource Management (DBRM)
3b. Plan Stability
3c. Cost-based Optimizer (CBO) Statistics
3d. Performance Summaries
3e. Operating System (OS) Statistics History
3h. Sessions
3i. JDBC Sessions
3j. Non-JDBC Sessions
3k. Data Guard Primary Site

4a. System Global Area (SGA) Statistics History
4b. Program Global Area (PGA) Statistics History
4c. Memory Statistics History
4d. System Time Model
4e. System Time Model Components
4f. Wait Times and Latency per Class
4g. Latency Histogram for Top 24 Wait Events
4h. Average Latency for Top 24 Wait Events
4i. Waits Count v.s. Average Latency for Top 24 Wait Events
4j. Parallel Execution
4k. System Metric History per Snap Interval
4l. System Metric Summary per Snap Interval

5a. Active Session History (ASH)
5b. Active Session History (ASH) on Wait Class
5c. Active Session History (ASH) on CPU and Top 24 Wait Events
5d. System Statistics per Snap Interval
5e. System Statistics (Exadata) per Snap Interval
5f. System Statistics (Current) per Snap Interval
5g. Exadata

6a. Active Session History (ASH) - Top Timed Classes
6b. Active Session History (ASH) - Top Timed Events
6c. Active Session History (ASH) - Top SQL
6d. Active Session History (ASH) - Top SQL - Time Series
6e. Active Session History (ASH) - Top Programs
6f. Active Session History (ASH) - Top Modules and Actions
6g. Active Session History (ASH) - Top Users
6h. Active Session History (ASH) - Top PLSQL Procedures
6i. Active Session History (ASH) - Top Data Objects
6j. Active Session History (ASH) - Service and User
6k. Active Session History (ASH) - Top PHV
6l. Active Session History (ASH) - Top Signature

7a. AWR/ADDM/ASH Reports
7b. SQL Sample

****************************************************************************************

Example runs 


Execute everything 
@edb360.sql T NULL


Execute only sections 1 to 6
@edb360.sql T 1-6


Execute only sections 1 to 7a
@edb360.sql T 1-7a


Execute only section 7
@edb360.sql T 7
