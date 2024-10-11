set echo off heading off feedback off verify off

DEFINE BEGIN_DATE = &1
DEFINE END_DATE = &2

PROMPT BEGIN Date  is: &BEGIN_DATE
PROMPT End Date is: &END_DATE


set pages 0 termout off

spool batch.sql
SELECT DISTINCT '@pcreport '
                                ||b.snap_id
                                ||' '
                                ||e.snap_id
                                ||' '
                                ||TO_CHAR(b.end_interval_time,'YYMMDD_HH24MI_')
                                ||TO_CHAR(e.end_interval_time,'HH24MI')
                                ||'.html' Commands,
                '-- '||TO_CHAR(b.end_interval_time,'yyyymmddHH24') lineorder
FROM            dba_hist_snapshot b,
                dba_hist_snapshot e
WHERE           b.end_interval_time>=to_date('&BEGIN_DATE','yyyymmddHH24')
AND             b.end_interval_time<=to_date('&END_DATE','yyyymmddHH24')
AND             e.snap_id           =b.snap_id+1
ORDER BY        lineorder
/
spool off

VARIABLE bid NUMBER;
VARIABLE eid NUMBER;
BEGIN
      SELECT min(snap_id)
        INTO :bid
        FROM dba_hist_snapshot
       WHERE TO_CHAR (end_interval_time, 'yyyymmddhh24') >= '&BEGIN_DATE';

      SELECT max(snap_id)
        INTO :eid
        FROM dba_hist_snapshot
        WHERE TO_CHAR (end_interval_time, 'yyyymmddhh24') <= '&END_DATE';
END;
/

spool big_range.sql

SELECT '@pcreport  '
       || :bid
       || ' '
       || :eid
       || ' '
       || 'full_range_'|| :bid || '_' || :eid || '.html'
FROM dual
/

spool off

host cat big_range.sql >> batch.sql
-- Reset terminal output and formatting
SET PAGESIZE 24


set termout on
select 'Generating Report Script batch.sql.....' from dual;
select 'Report file created for snap_ids between:', '&&BEGIN_DATE', '&&END_DATE', 'Check file batch.sql' from dual;
set echo on termout on verify on heading on feedback on
exit;
