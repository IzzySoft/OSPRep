#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html       (c) 2003 by IzzySoft (devel@izzysoft.de)     
# -----------------------------------------------------------------------------
# This report script creates a HTML document containing the StatsPack Report.
# It is a simple rewrite of the standard sprepins.sql script
# I'ld never claim this report tool to be perfect, complete or "state of the
# art". But it's simple to use and very helpful to those not having a license
# to the expensive AddOns available at Oracle. Any hints on errors or bugs as
# well as recommendations for additions are always welcome.
#                                                              Itzchak Rehberg
#
#
version='0.0.5'
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OSPRep v$version                (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
  echo ----------------------------------------------------------------------------
  echo This script is intended to generate a HTML report for the Oracle StatsPack
  echo collected statistics. Look inside the script header for closer details, and
  echo check for the configuration there as well.
  echo ----------------------------------------------------------------------------
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [StartDir]"
  echo ============================================================================
  echo
  exit 1
fi

# =================================================[ Configuration Section ]===
# SID of the database to analyse
export ORACLE_SID=$1
# in which directory should the report ($ORACLE_SID.html) be placed
REPDIR=/var/www/html/statspack
# StyleSheet to use
CSS=../main.css
# login information
user=perfstat
password="pyha#"
# Top settings
TOP_N_SQL=5

#--- temporary settings:
START_ID=1
END_ID=6

# If called from another script, we may have to change to another directory
# before generating the reports
if [ -n "$2" ]; then
  cd $2
fi

# ====================================================[ Script starts here ]===
#$ORACLE_HOME/bin/sqlplus -s $user/$password <<EOF
$ORACLE_HOME/bin/sqlplus -s /NOLOG <<EOF

CONNECT $user/$password@$1
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${ORACLE_SID}.html

DECLARE
  L_LINE VARCHAR2(4000);
  R_TITLE VARCHAR(200);
  TABLE_OPEN VARCHAR(100); -- Table Attributes
  TABLE_CLOSE VARCHAR(100);
  S1 VARCHAR(200);
  S2 VARCHAR(200);
  S3 VARCHAR(200);
  S4 VARCHAR(200);
  S5 VARCHAR(200);
  I1 NUMBER;
  I2 NUMBER;
  I3 NUMBER;
  BID NUMBER; EID NUMBER; ELA NUMBER; EBGT NUMBER; EDRT NUMBER; EET NUMBER;
  EPC NUMBER;
  DBID NUMBER; DB_NAME VARCHAR(9); INST_NUM NUMBER; INST_NAME VARCHAR(16);
  PARA VARCHAR2(3); VERSN VARCHAR(17); HOST_NAME VARCHAR(64);
  LHTR NUMBER; BFWT NUMBER; TRAN NUMBER; CHNG NUMBER; UCAL NUMBER; UROL NUMBER;
  UCOM NUMBER; RSIZ NUMBER; PHYR NUMBER; PHYRD NUMBER; PHYRDL NUMBER;
  PHYW NUMBER; PRSE NUMBER; HPRS NUMBER; RECR NUMBER; GETS NUMBER; RLSR NUMBER;
  RENT NUMBER; SRTM NUMBER; SRTD NUMBER; SRTR NUMBER; STRN NUMBER; CALL NUMBER;
  LHR NUMBER; SP VARCHAR2(512); BC VARCHAR2(512); LB VARCHAR2(512); BS VARCHAR2(512);
  TWT NUMBER; LOGC NUMBER; PRSCPU NUMBER; PRSELA NUMBER; TCPU NUMBER; EXE NUMBER;
  BSPM NUMBER; ESPM NUMBER; BFRM NUMBER; EFRM NUMBER; BLOG NUMBER; ELOG NUMBER;
  BOCUR NUMBER; EOCUR NUMBER; DMSD NUMBER; DMFC NUMBER; DMSI NUMBER; PMRV NUMBER;
  PMPT NUMBER; NPMRV NUMBER; NPMPT NUMBER; DPMS NUMBER; DNPMS NUMBER;
  GLSG NUMBER; GLAG NUMBER; GLGT NUMBER; GLSC NUMBER; GLAC NUMBER; GLCT NUMBER;
  GLRL NUMBER; GCGE NUMBER; GCGT NUMBER; GCCV NUMBER; GCCT NUMBER;
  GCCRRV NUMBER; GCCRRT NUMBER; GCCURV NUMBER; GCCURT NUMBER; GCCRSV NUMBER;
  GCCRBT NUMBER; GCCRFT NUMBER; GCCRST NUMBER; GCCUSV NUMBER; GCCUPT NUMBER;
  GCCUFT NUMBER; GCCUST NUMBER;
  /* StatsPack ab Oracle v9.2 Start
      DBFR NUMBER; GCDFR NUMBER; MSGSQ NUMBER; MSGSQT NUMBER; MSGSQK NUMBER;
      MSGSQTK NUMBER; MSGRQ NUMBER; MSGRQT NUMBER;
     StatsPack ab Oracle v9.2 END */
  -- StatsPack vor Oracle v9.2 Start
  DFCMS NUMBER; DFCMR NUMBER; DMRV NUMBER; DYNAL NUMBER; SCMA NUMBER; SCML NUMBER;
  PINC NUMBER; PINCRNC NUMBER; PICC NUMBER; PICRRC NUMBER; PBC NUMBER;
  PBCRC NUMBER; PCRBPI NUMBER; DYNAPRES NUMBER; DYNAPSHL NUMBER; PRCMA NUMBER;
  PRCML NUMBER; PWRM NUMBER; PFPIM NUMBER; PWNM NUMBER; DYNARES NUMBER;
  PCBA NUMBER; PCCRBA NUMBER;
  -- StatsPack vor Oracle v9.2 END

  CURSOR C_SnapBind1 (db_id IN NUMBER, instnum IN NUMBER) IS
    SELECT parallel,version,host_name
      FROM stats\$database_instance di,stats\$snapshot s
     WHERE s.snap_id=$START_ID AND s.dbid=db_id AND s.instance_number=instnum
       AND di.dbid=s.dbid AND di.instance_number=s.instance_number
       AND di.startup_time=s.startup_time;

  CURSOR C_SnapInfo IS
    SELECT b.snap_id begin_snap_id,to_char(b.snap_time,'dd.mm.yyyy hh24:mi') begin_snap_time,
           NVL(b.ucomment,'&nbsp;') begin_snap_comment,
	   e.snap_id end_snap_id,to_char(e.snap_time,'dd.mm.yyyy hh24:mi') end_snap_time,
	   NVL(e.ucomment,'&nbsp;') end_snap_comment,
	   to_char(round(((e.snap_time - b.snap_time) * 1440 * 60),0)/60,'9,990.00') elapsed,
	   (e.snap_time - b.snap_time)*1440*60 ela,
	   e.buffer_gets_th ebgt,
	   e.disk_reads_th edrt,
	   e.executions_th eet,
	   e.parse_calls_th epc
      FROM stats\$snapshot b, stats\$snapshot e
     WHERE b.snap_id=$START_ID
       AND e.snap_id=$END_ID
--       AND b.dbid=
--       AND e.dbid=
--       AND b.instance_number=
--       AND e.instance_number=
       AND b.startup_time=e.startup_time
       AND b.snap_time < e.snap_time;

  CURSOR C_SPSQL (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT (100*(1-b.single_use_sql/b.total_sql)) AS b_single_sql,
           (100*(1-e.single_use_sql/e.total_sql)) AS e_single_sql,
	   (100*(1-b.single_use_sql_mem/b.total_sql_mem)) AS b_single_mem,
	   (100*(1-e.single_use_sql_mem/e.total_sql_mem)) AS e_single_mem
      FROM stats\$sql_statistics b, stats\$sql_statistics e
     WHERE b.snap_id=bid
       AND e.snap_id=eid
       AND b.instance_number=instnum
       AND e.instance_number=instnum
       AND b.dbid=db_id
       AND e.dbid=db_id;

  CURSOR C_Top5 (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, twt IN NUMBER) IS
    SELECT event, waits, time, pctwtt
      FROM ( SELECT e.event event,
                    to_char(e.total_waits - NVL(b.total_waits,0),'9,999,999,999') waits,
		    to_char((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000,'9,999,990.00') time,
		    decode(twt,0,'0.00',
		      to_char(100*((e.time_waited_micro - NVL(b.time_waited_micro,0))/twt),'9,990.00')) pctwtt
	       FROM stats\$system_event b, stats\$system_event e
	      WHERE b.snap_id(+) = bid
	        AND e.snap_id    = eid
		AND b.dbid(+)    = db_id
		AND e.dbid       = db_id
		AND b.instance_number(+) = instnum
		AND e.instance_number    = instnum
		AND b.event(+)   = e.event
		AND e.event NOT IN ( SELECT event FROM stats\$idle_event )
	      ORDER BY time desc, waits desc )
     WHERE rownum <= 5;

  CURSOR C_AllWait (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, tran NUMBER) IS
    SELECT e.event event,
           to_char(e.total_waits - NVL(b.total_waits,0),'9,999,999,999') waits,
	   to_char(e.total_timeouts - NVL(b.total_timeouts,0),'999,999') timeouts,
	   to_char((e.time_waited_micro - NVL(b.time_waited_micro,0))/1000000,'99,999,990.00') time,
	   decode ((e.total_waits - NVL(b.total_waits,0)),
	          0,'0.00',to_char(
		    ((e.time_waited_micro - NVL(b.time_waited_micro,0))/1000)
		    / (e.total_waits - NVL(b.total_waits,0)),'9,999,990.00') ) wt,
	   to_char((e.total_waits - NVL(b.total_waits,0))/tran,'99,990.00') txwaits,
	   decode(i.event,NULL,0,99) idle
      FROM stats\$system_event b, stats\$system_event e, stats\$idle_event i
     WHERE b.snap_id(+)  = bid
       AND e.snap_id     = eid
       AND b.dbid(+)     = db_id
       AND e.dbid        = db_id
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.event(+)    = e.event
       AND e.total_waits > NVL(b.total_waits,0)
       AND e.event NOT LIKE '%timer%'
       AND e.event NOT LIKE 'rdbms ipc%'
       AND i.event(+)    = e.event
     ORDER BY idle, time desc, waits desc;

  CURSOR C_BGWait (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, tran NUMBER) IS
    SELECT e.event event,
           to_char(e.total_waits - NVL(b.total_waits,0),'9,999,999,999') waits,
	   to_char(e.total_timeouts - NVL(b.total_timeouts,0),'999,999') timeouts,
	   to_char((e.time_waited_micro - NVL(b.time_waited_micro,0))/1000000,'99,999,990.00') time,
	   decode ((e.total_waits - NVL(b.total_waits,0)),
	          0,'0.00',to_char(
		    ((e.time_waited_micro - NVL(b.time_waited_micro,0))/1000)
		    / (e.total_waits - NVL(b.total_waits,0)),'9,999,990.00') ) wt,
	   to_char((e.total_waits - NVL(b.total_waits,0))/tran,'99,990.00') txwaits,
	   decode(i.event,NULL,0,99) idle
      FROM stats\$bg_event_summary b, stats\$bg_event_summary e, stats\$idle_event i
     WHERE b.snap_id(+)  = bid
       AND e.snap_id     = eid
       AND b.dbid(+)     = db_id
       AND e.dbid        = db_id
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.event(+)    = e.event
       AND e.total_waits > NVL(b.total_waits,0)
       AND i.event(+)    = e.event
     ORDER BY idle, time desc, waits desc;

  CURSOR C_SQLByGets (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, gets IN NUMBER) IS
    SELECT bufgets,execs,getsperexec,pcttotal,cputime,elapsed,hashval
      FROM ( SELECT /*+ ordered use_nl (b st) */
              to_char((e.buffer_gets - nvl(b.buffer_gets,0)),'99,999,999,990') bufgets,
	      to_char((e.executions - nvl(b.executions,0)),'999,999,999') execs,
	      to_char(decode(e.executions - nvl(b.executions,0),
			         0, '&nbsp;',
				 (e.buffer_gets - nvl(b.buffer_gets,0)) /
				 (e.executions - nvl(b.executions,0))),
				 '999,999,990.0') getsperexec,
	      to_char(100*(e.buffer_gets - nvl(b.buffer_gets,0))/gets,
			  '990.0') pcttotal,
	      nvl(to_char( (e.cpu_time - nvl(b.cpu_time,0))/1000000,
			  '99,990.00'),'0.00') cputime,
	      nvl(to_char( (e.elapsed_time - nvl(b.elapsed_time,0))
			/ 1000000,'99,990.00'), '0.00') elapsed,
	      NVL ( e.hash_value,0 ) hashval
	      FROM stats\$sql_summary e, stats\$sql_summary b
	     WHERE b.snap_id(+)  = bid
	       AND b.dbid(+)     = e.dbid
	       AND b.instance_number(+) = e.instance_number
	       AND b.hash_value(+)      = e.hash_value
	       AND b.address(+)  = e.address
	       AND b.text_subset(+)     = e.text_subset
	       AND e.snap_id     = eid
	       AND e.dbid        = db_id
	       AND e.instance_number    = instnum
	       AND e.executions  > nvl(b.executions,0)
	     ORDER BY (e.buffer_gets - nvl(b.buffer_gets,0)) desc,
	              e.hash_value
	   )
     WHERE rownum <= $TOP_N_SQL;

  CURSOR C_SQLByReads (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, phyr IN NUMBER) IS
    SELECT phyreads,execs,readsperexec,pcttotal,cputime,elapsed,hashval
      FROM ( SELECT /*+ ordered use_nl (b st) */
              to_char((e.disk_reads - nvl(b.disk_reads,0)),'99,999,999,990') phyreads,
	      to_char((e.executions - nvl(b.executions,0)),'999,999,999') execs,
	      to_char(decode(e.executions - nvl(b.executions,0),
			         0, '&nbsp;',
				 (e.disk_reads - nvl(b.disk_reads,0)) /
				 (e.executions - nvl(b.executions,0))),
				 '999,999,990.0') readsperexec,
	      to_char(100*(e.buffer_gets - nvl(b.buffer_gets,0))/phyr,
			  '990.0') pcttotal,
	      nvl(to_char( (e.cpu_time - nvl(b.cpu_time,0))/1000000,
			  '99,990.00'),'0.00') cputime,
	      nvl(to_char( (e.elapsed_time - nvl(b.elapsed_time,0))
			/ 1000000,'99,990.00'), '0.00') elapsed,
	      NVL ( e.hash_value,0 ) hashval
	      FROM stats\$sql_summary e, stats\$sql_summary b
	     WHERE b.snap_id(+)  = bid
	       AND b.dbid(+)     = e.dbid
	       AND b.instance_number(+) = e.instance_number
	       AND b.hash_value(+)      = e.hash_value
	       AND b.address(+)  = e.address
	       AND b.text_subset(+)     = e.text_subset
	       AND e.snap_id     = eid
	       AND e.dbid        = db_id
	       AND e.instance_number    = instnum
	       AND e.executions  > nvl(b.executions,0)
	       AND phyr          > 0
	     ORDER BY (e.disk_reads - nvl(b.disk_reads,0)) desc,
	              e.hash_value
	   )
     WHERE rownum <= $TOP_N_SQL;

  CURSOR C_SQLByExec (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT execs,rowsproc,rowsperexec,cputime,elapsed,hashval
      FROM ( SELECT /*+ ordered use_nl (b st) */
	      to_char((e.executions - nvl(b.executions,0)),'999,999,999') execs,
	      to_char((nvl(e.rows_processed,0) - nvl(b.rows_processed,0)),
	             '99,999,999,999') rowsproc,
	      to_char(decode(nvl(e.rows_processed,0) - nvl(b.rows_processed,0),
			         0, 0,
				 (e.rows_processed - nvl(b.rows_processed,0)) /
				 (e.executions - nvl(b.executions,0))),
				 '9,999,999,990.0') rowsperexec,
	      nvl(to_char( (e.cpu_time - nvl(b.cpu_time,0)) /
	                   (e.executions - nvl(b.executions,0)),
			  '9,999,999,990.00'),'0.00') cputime,
	      nvl(to_char( (e.elapsed_time - nvl(b.elapsed_time,0)) /
	                   (e.executions - nvl(b.executions,0)),
			'999,990.00'), '0.00') elapsed,
	      NVL ( e.hash_value,0 ) hashval
	      FROM stats\$sql_summary e, stats\$sql_summary b
	     WHERE b.snap_id(+)  = bid
	       AND b.dbid(+)     = e.dbid
	       AND b.instance_number(+) = e.instance_number
	       AND b.hash_value(+)      = e.hash_value
	       AND b.address(+)  = e.address
	       AND b.text_subset(+)     = e.text_subset
	       AND e.snap_id     = eid
	       AND e.dbid        = db_id
	       AND e.instance_number    = instnum
	       AND e.executions  > nvl(b.executions,0)
	       AND phyr          > 0
	     ORDER BY (e.executions - nvl(b.executions,0)) desc,
	              e.hash_value
	   )
     WHERE rownum <= $TOP_N_SQL;

  CURSOR C_SQLByParse (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, prse IN NUMBER) IS
    SELECT parses,execs,pctparses,hashval
      FROM ( SELECT /*+ ordered use_nl (b st) */
              to_char((e.parse_calls - nvl(b.parse_calls,0)),'999,999,990') parses,
	      to_char((e.executions - nvl(b.executions,0)),'999,999,990') execs,
	      to_char((nvl(e.parse_calls,0) - nvl(b.parse_calls,0))/prse,
	             '990.00') pctparses,
	      NVL ( e.hash_value,0 ) hashval
	      FROM stats\$sql_summary e, stats\$sql_summary b
	     WHERE b.snap_id(+)  = bid
	       AND b.dbid(+)     = e.dbid
	       AND b.instance_number(+) = e.instance_number
	       AND b.hash_value(+)      = e.hash_value
	       AND b.address(+)  = e.address
	       AND b.text_subset(+)     = e.text_subset
	       AND e.snap_id     = eid
	       AND e.dbid        = db_id
	       AND e.instance_number    = instnum
	     ORDER BY (e.parse_calls - nvl(b.parse_calls,0)) desc,
	              e.hash_value
	   )
     WHERE rownum <= $TOP_N_SQL;

  CURSOR C_GetSQL (hv IN NUMBER) IS
    SELECT sql_text FROM stats\$sqltext WHERE hash_value=hv
     ORDER BY piece;

  CURSOR C_InstAct (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, ela IN NUMBER, tran IN NUMBER) IS
    SELECT b.name name,
           to_char(e.value - b.value,'99,999,999,999,990') total,
	   to_char(round((e.value - b.value)/ela,2),'99,999,999,990.00') sec,
	   to_char(round((e.value - b.value)/tran,2),'99,999,999,990.00') txn
      FROM stats\$sysstat b, stats\$sysstat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.name    = e.name
       AND e.name NOT IN ( 'logons current','opened cursors current','workarea memory allocated')
       AND e.value   > b.value
       AND e.value   > 0
     ORDER BY b.name;

  CURSOR C_TSIO (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, ela IN NUMBER) IS
    SELECT e.tsname tsname,
           to_char(sum(e.phyrds - nvl(b.phyrds,0)),'9,999,999,990') reads,
	   to_char(sum(e.phyrds - nvl(b.phyrds,0))/ela,'9,990.00') rps,
	   to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10),
		   '9,990.0') avgrd,
	   to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
	   to_char(sum(e.phywrts - nvl(b.phywrts,0)),'9,999,999,990') writes,
	   to_char(sum(e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
	   to_char(sum(e.wait_count - nvl(b.wait_count,0)),'99,990') waits,
	   to_char(decode(sum(e.wait_count - nvl(b.wait_count,0)),
	           0,0,
		   (sum(e.time - nvl(b.time,0)) /
		    sum(e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
	   sum(e.phywrts - nvl(b.phywrts,0)) +
	   sum(e.phyrds - nvl(b.phyrds,0)) ios
      FROM stats\$filestatxs e, stats\$filestatxs b
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.tsname(+)  = e.tsname
       AND b.filename(+)= e.filename
       AND ( (e.phyrds - nvl(b.phyrds,0) ) +
             (e.phywrts - nvl(b.phywrts,0) ) ) > 0
     GROUP BY e.tsname
    UNION SELECT e.tsname tsname,
           to_char(sum(e.phyrds - nvl(b.phyrds,0)),'9,999,999,990') reads,
	   to_char(sum(e.phyrds - nvl(b.phyrds,0))/ela,'9,990.00') rps,
	   to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10),
		   '9,990.0') avgrd,
	   to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
	   to_char(sum(e.phywrts - nvl(b.phywrts,0)),'9,999,999,990') writes,
	   to_char(sum(e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
	   to_char(sum(e.wait_count - nvl(b.wait_count,0)),'99,990') waits,
	   to_char(decode(sum(e.wait_count - nvl(b.wait_count,0)),
	           0,0,
		   (sum(e.time - nvl(b.time,0)) /
		    sum(e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
	   sum(e.phywrts - nvl(b.phywrts,0)) +
	   sum(e.phyrds - nvl(b.phyrds,0)) ios
      FROM stats\$tempstatxs e, stats\$tempstatxs b
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.tsname(+)  = e.tsname
       AND b.filename(+)= e.filename
       AND ( (e.phyrds - nvl(b.phyrds,0) ) +
             (e.phywrts - nvl(b.phywrts,0) ) ) > 0
     GROUP BY e.tsname
     ORDER BY ios desc;

  CURSOR C_FileIO (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, ela IN NUMBER) IS
    SELECT e.tsname tsname,
           e.filename filename,
           to_char(e.phyrds - nvl(b.phyrds,0),'9,999,999,990') reads,
	   to_char((e.phyrds - nvl(b.phyrds,0))/ela,'9,990.00') rps,
	   to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / 
		    (e.phyrds - nvl(b.phyrds,0))) * 10),
		   '9,990.0') avgrd,
	   to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
	   to_char(e.phywrts - nvl(b.phywrts,0),'9,999,999,990') writes,
	   to_char((e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
	   to_char(e.wait_count - nvl(b.wait_count,0),'99,990') waits,
	   to_char(decode(e.wait_count - nvl(b.wait_count,0),
	           0,0,
		   ((e.time - nvl(b.time,0)) /
		    (e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw
      FROM stats\$filestatxs e, stats\$filestatxs b
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.tsname(+)  = e.tsname
       AND b.filename(+)= e.filename
       AND ( (e.phyrds - nvl(b.phyrds,0) ) +
             (e.phywrts - nvl(b.phywrts,0) ) ) > 0
    UNION SELECT e.tsname tsname,
           e.filename filename,
           to_char(e.phyrds - nvl(b.phyrds,0),'9,999,999,990') reads,
	   to_char((e.phyrds - nvl(b.phyrds,0))/ela,'9,990.00') rps,
	   to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / (e.phyrds - nvl(b.phyrds,0))) * 10),
		   '9,990.0') avgrd,
	   to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
	   to_char(e.phywrts - nvl(b.phywrts,0),'9,999,999,990') writes,
	   to_char((e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
	   to_char(e.wait_count - nvl(b.wait_count,0),'99,990') waits,
	   to_char(decode(e.wait_count - nvl(b.wait_count,0),
	           0,0,
		   ((e.time - nvl(b.time,0)) /
		    (e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw
      FROM stats\$tempstatxs e, stats\$tempstatxs b
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.tsname(+)  = e.tsname
       AND b.filename(+)= e.filename
       AND ( (e.phyrds - nvl(b.phyrds,0) ) +
             (e.phywrts - nvl(b.phywrts,0) ) ) > 0
     ORDER BY tsname,filename;

  CURSOR C_BuffP (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, bs IN NUMBER) IS
    SELECT replace(e.block_size/1024||'k',bs/1024||'k',substr(e.name,1,1)) name,
           e.set_msize numbufs,
	   to_char(decode(  e.db_block_gets   - nvl(b.db_block_gets,0)
	                  + e.consistent_gets - nvl(b.consistent_gets,0),
		     0, to_number(NULL),
		     (100* (1- (  (e.physical_reads  - nvl(b.physical_reads,0))
		                / (  e.db_block_gets   - nvl(b.db_block_gets,0)
				   + e.consistent_gets - nvl(b.consistent_gets,0))
			       ) ) ) ),'990.9' ) hitratio,
	   to_char(  e.db_block_gets   - nvl(b.db_block_gets,0)
	           + e.consistent_gets - nvl(b.consistent_gets,0),
		   '99,999,999,999') gets,
	   to_char(e.physical_reads - nvl(b.physical_reads,0),
	           '99,999,999,999') phread,
	   to_char(e.physical_writes - nvl(b.physical_writes,0),
	           '999,999,999') phwrite,
	   to_char(e.free_buffer_wait - nvl(b.free_buffer_wait,0),
	           '999,999') fbwait,
	   to_char(e.write_complete_wait - nvl(b.write_complete_wait,0),
	           '999,999') wcwait,
	   to_char(e.buffer_busy_wait - nvl(b.buffer_busy_wait,0),
	           '9,999,999') bbwait
      FROM stats\$buffer_pool_statistics b, stats\$buffer_pool_statistics e
     WHERE b.snap_id(+)  = bid
       AND e.snap_id     = eid
       AND b.dbid(+)     = db_id
       AND e.dbid        = db_id
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.id(+)       = e.id
     ORDER BY e.name;
		  
  CURSOR C_Recover (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT 'B' name,
           to_char(target_mttr,'999,999') tm,
	   to_char(estimated_mttr,'999,999') em,
	   to_char(recovery_estimated_ios,'9,999,999') rei,
	   to_char(actual_redo_blks,'99,999,999') arb,
	   to_char(target_redo_blks,'99,999,999') trb,
	   to_char(log_file_size_redo_blks,'99,999,999') lfrb,
	   to_char(log_chkpt_timeout_redo_blks,'99,999,999') lctrb,
	   to_char(log_chkpt_interval_redo_blks,'99,999,999,999') lcirb,
	   snap_id snid
      FROM stats\$instance_recovery b
     WHERE b.snap_id = bid
       AND b.dbid    = db_id
       AND b.instance_number = instnum
    UNION SELECT 'E' name,
           to_char(target_mttr,'999,999') tm,
	   to_char(estimated_mttr,'999,999') em,
	   to_char(recovery_estimated_ios,'9,999,999') rei,
	   to_char(actual_redo_blks,'99,999,999') arb,
	   to_char(target_redo_blks,'99,999,999') trb,
	   to_char(log_file_size_redo_blks,'99,999,999') lfrb,
	   to_char(log_chkpt_timeout_redo_blks,'99,999,999') lctrb,
	   to_char(log_chkpt_interval_redo_blks,'99,999,999,999') lcirb,
	   snap_id snid
      FROM stats\$instance_recovery e
     WHERE e.snap_id = eid
       AND e.dbid    = db_id
       AND e.instance_number = instnum
     ORDER BY snid;

  CURSOR C_BuffW (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT e.class class,
           to_char(e.wait_count - nvl(b.wait_count,0),'999,999') icnt,
	   to_char((e.time - nvl(b.time,0))/100,'999,990.00') itim,
	   to_char((e.time - nvl(b.time,0)) /
	   (e.wait_count - nvl(b.wait_count,0)) * 10,'999,990.00') iavg
      FROM stats\$waitstat b, stats\$waitstat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.class   = e.class
       AND b.wait_count < e.wait_count
     ORDER BY itim desc, icnt desc;

  CURSOR C_PGAA (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT 'B' snap,
           to_char(to_number(p.value)/1024/1024,'999,990.00')  pgaat,
	   to_char(mu.PGA_inuse/1024/1024,'999,990.00')        tot_pga_used,
	   to_char( (mu.PGA_used_auto + mu.PGA_used_man)
	            /1024/1024,'999,990.00')                   tot_tun_used,
	   to_char(mu.onepr/1024/1024,'999,990.00')            onepr,
	   to_char(s.opt_pct,'990.00')                         opt_pct,
	   to_char(100*(mu.PGA_inuse - mu.PGA_used_auto
	            - mu.PGA_used_man)/ PGA_inuse,'990.00')    pct_unt,
           to_char(100* mu.PGA_used_auto / PGA_inuse,'990.00') pct_auto_tun,
	   to_char(100* mu.PGA_used_man  / PGA_inuse,'990.00') pct_man_tun
      FROM ( SELECT sum(case when name like 'total PGA inuse%'
                             then value else 0 end)             PGA_inuse,
		    sum(case when name like 'total PGA used for auto%'
                             then value else 0 end)             PGA_used_auto,
		    sum(case when name like 'total PGA used for manual%'
                             then value else 0 end)             PGA_used_man,
		    sum(case when name like 'maximum % one-pass'
                             then value else 0 end)             onepr
	       FROM stats\$pgastat pga
	      WHERE pga.snap_id = bid
	        AND pga.dbid    = db_id
		AND pga.instance_number = instnum ) mu,
           ( SELECT 100* sum(case when ss.name like
                              'workarea executions - optimal'
			      then ss.value else 0 end)
		       / decode( (  sum(case when ss.name like
		                     'workarea executions - optimal'
				     then ss.value else 0 end)
				  + sum(case when ss.name like
				     'workarea executions - onepass'
				     then ss.value else 0 end)
				  + sum(case when ss.name like
				     'workarea executions - multipass'
				     then ss.value else 0 end)
				 ),0,NULL)                     opt_pct
	      FROM stats\$sysstat ss
	     WHERE ss.snap_id = bid
	       AND ss.dbid    = db_id
	       AND ss.instance_number = instnum
	       AND ss.name like 'workarea executions - %'
	   ) s,
	   stats\$parameter p
     WHERE p.snap_id = bid
       AND p.dbid    = db_id
       AND p.instance_number = instnum
       AND p.name    = 'pga_aggregate_target'
       AND p.value  != 0
    UNION SELECT 'E' snap,
           to_char(to_number(p.value)/1024/1024,'999,990.00')  pgaat,
	   to_char(mu.PGA_inuse/1024/1024,'999,990.00')        tot_pga_used,
	   to_char( (mu.PGA_used_auto + mu.PGA_used_man)
	            /1024/1024,'999,990.00')                   tot_tun_used,
	   to_char(mu.onepr/1024/1024,'999,990.00')            onepr,
	   to_char(s.opt_pct,'990.00')                         opt_pct,
	   to_char(100*(mu.PGA_inuse - mu.PGA_used_auto
	            - mu.PGA_used_man)/ PGA_inuse,'990.00')    pct_unt,
           to_char(100* mu.PGA_used_auto / PGA_inuse,'990.00') pct_auto_tun,
	   to_char(100* mu.PGA_used_man  / PGA_inuse,'990.00') pct_man_tun
      FROM ( SELECT sum(case when name like 'total PGA inuse%'
                             then value else 0 end)             PGA_inuse,
		    sum(case when name like 'total PGA used for auto%'
                             then value else 0 end)             PGA_used_auto,
		    sum(case when name like 'total PGA used for manual%'
                             then value else 0 end)             PGA_used_man,
		    sum(case when name like 'maximum % one-pass'
                             then value else 0 end)             onepr
	       FROM stats\$pgastat pga
	      WHERE pga.snap_id = eid
	        AND pga.dbid    = db_id
		AND pga.instance_number = instnum ) mu,
           ( SELECT 100* sum(case when ss.name like
                              'workarea executions - optimal'
			      then ss.value else 0 end)
		       / decode( (  sum(case when ss.name like
		                     'workarea executions - optimal'
				     then ss.value else 0 end)
				  + sum(case when ss.name like
				     'workarea executions - onepass'
				     then ss.value else 0 end)
				  + sum(case when ss.name like
				     'workarea executions - multipass'
				     then ss.value else 0 end)
				 ),0,NULL)                     opt_pct
	      FROM stats\$sysstat ss
	     WHERE ss.snap_id = eid
	       AND ss.dbid    = db_id
	       AND ss.instance_number = instnum
	       AND ss.name like 'workarea executions - %'
	   ) s,
	   stats\$parameter p
     WHERE p.snap_id = eid
       AND p.dbid    = db_id
       AND p.instance_number = instnum
       AND p.name    = 'pga_aggregate_target'
       AND p.value  != 0;


BEGIN
  -- Configuration
  BID := $START_ID; EID := $END_ID;
  dbms_output.enable(1000000);
  R_TITLE := 'StatsPack Report for $ORACLE_SID';
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  SELECT d.dbid,d.name,i.instance_number,i.instance_name
    INTO DBID,DB_NAME,INST_NUM,INST_NAME
    FROM v\$database d,v\$instance i;

  FOR R_SnapBind1 IN C_SnapBind1(DBID,INST_NUM) LOOP
    PARA  := R_SnapBind1.parallel;
    VERSN := R_SnapBind1.version;
    HOST_NAME := R_SnapBind1.host_name;
  END LOOP;

  -- HTML Head
  L_LINE := '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="$CSS">'||CHR(10)||
            '</HEAD><BODY>'||CHR(10)||'<H2>'||R_TITLE||'</H2>'||CHR(10);
  dbms_output.put_line(L_LINE);

  -- Navigation
  L_LINE := TABLE_OPEN||'<TR><TD ALIGN="center"><FONT SIZE=-2>[ <A HREF="#snapinfo">SnapShot Info</A> ] '||
            '[ <A HREF="#cachesizes">Cache Sizes</A> ] [ <A HREF="#loads">Load Profile</A> '||
            '] [ <A HREF="#efficiency">Efficiency</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE :=   ' [ <A HREF="#sharedpool">Shared Pool</A> ] [ <A HREF="#top5wait">Top 5 Wait</A>'||
            ' ] [ <A HREF="#waitevents">Wait Events</A> ] [ <A HREF="#bgwaitevents">Background Waits</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#sqlbygets">SQL by Gets</A> ] [ <A HREF="#sqlbyreads">SQL by Reads</A> ]'||
	    ' [ <A HREF="#sqlbyexec">SQL by Exec</A> ] [ <A HREF="#sqlbyparse">SQL by Parse</A> ]'||
	    ' [ <A HREF="#instact">Instance Activity</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#tsio">TableSpace IO</A> ] [ <A HREF="#fileio">File IO</A> ]'||
            ' [ <A HREF="#bufpool">Buffer Pool</A> ] [ <A HREF="#recover">Instance Recovery</A> ]'||
	    ' [ <A HREF="#bufwait">Buffer Waits</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#pga">Memory Stats</A> ]</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Initial information about this instance
  SELECT to_char(SYSDATE,'DD.MM.YYYY HH24:MI') INTO S5 FROM DUAL;
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Common Instance Information</TH></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Hostname:</TD><TD>'||HOST_NAME||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Instance:</TD><TD>'||INST_NAME||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Version:</TD><TD>'||VERSN||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Cluster:</TD><TD>'||PARA||'</TD></TR>'||CHR(10);
  dbms_output.put_line(L_LINE);
  SELECT SUM(members*bytes) INTO I1 FROM v\$log;
  SELECT SUM(bytes) INTO I2 from v\$datafile;
  I3 := (I1+I2)/1048576;
  S1 := to_char(I3,'999,999,999.99');
  SELECT to_char(startup_time,'DD.MM.YYYY HH24:MI'),to_char(sysdate - startup_time,'9990.00')
    INTO S2,S3 FROM v\$instance;
  L_LINE := ' <TR><TD class="td_name">FileSize (Data+Log)</TD><TD>'||S1||' MB</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Startup / Uptime</TD><TD>'||S2||' / '||S3||' d</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Report generated:</TD><TD>'||S5||'</TD></TR>'||CHR(10)||
            TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Collect Changes from statspack
  statspack.stat_changes (
   BID, EID,
   DBID, INST_NUM,
   PARA,           -- End of IN arguments
   LHTR, BFWT,
   TRAN, CHNG,
   UCAL, UROL,
   RSIZ,
   PHYR, PHYRD,
   PHYRDL,
   PHYW, UCOM,
   PRSE, HPRS,
   RECR, GETS,
   RLSR, RENT,
   SRTM, SRTD,
   SRTR, STRN,
   LHR, BC,
   SP, LB,
   BS, TWT,
   LOGC, PRSCPU,
   TCPU, EXE,
   PRSELA,
   BSPM, ESPM,
   BFRM, EFRM,
   BLOG, ELOG,
   BOCUR, EOCUR,
   DMSD, DMFC,   -- Begin of RAC
   DFCMS, DFCMR, -- entfaellt ab v9.2
   DMSI,
   DMRV, DYNAL,  -- entfaellt ab v9.2
   DYNARES,      -- dito
   PMRV, PMPT,
   NPMRV, NPMPT,
   SCMA, SCML,   -- entfaellt ab v9.2
   PINC, PINCRNC,-- dito
   PICC, PICRRC, -- dito
   PBC, PBCRC,   -- dito
   PCBA, PCCRBA, -- dito
   PCRBPI,       -- dito
   DYNAPRES, DYNAPSHL, -- dito
   PRCMA, PRCML, -- dito
   PWRM, PFPIM,  -- dito
   PWNM,         -- dito
--   DBFR,       -- ab v9.2 benoetigt
   DPMS, DNPMS,
   GLSG, GLAG,
   GLGT, GLSC,
   GLAC, GLCT,
   GLRL,
--   GCDFR,      -- ab v9.2 benoetigt
   GCGE, GCGT,
   GCCV, GCCT,
   GCCRRV, GCCRRT,
   GCCURV, GCCURT,
   GCCRSV,
   GCCRBT, GCCRFT,
   GCCRST, GCCUSV,
   GCCUPT, GCCUFT,
   GCCUST
-- ,  MSGSQ, MSGSQT,   -- ab v9.2 benoetigt
--   MSGSQK, MSGSQTK, -- dito
--   MSGRQ, MSGRQT    -- dito
  );
  CALL := UCAL + RECR;

  -- SnapShot Info
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="#snapinfo">SnapShot Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Snap ID</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TH CLASS="th_sub">Snap Time</TH><TH CLASS="th_sub">Sessions</TH>'||
            '<TH CLASS="th_sub">Curs/Sess</TH><TH CLASS="th_sub">Comment</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_SnapInfo IN C_SnapInfo LOOP
    L_LINE := ' <TR><TD>Start</TD><TD ALIGN="right">'||Rec_SnapInfo.begin_snap_id||'</TD><TD>'||
              Rec_SnapInfo.begin_snap_time||'</TD><TD ALIGN="right">'||BLOG||'</TD><TD ALIGN="right">'||
	      to_char(BOCUR/BLOG,'9,990.00')||'<TD>'||Rec_SnapInfo.begin_snap_comment||'</TD></TR>';
    dbms_output.put_line(L_LINE);
    L_LINE := ' <TR><TD>End</TD><TD ALIGN="right">'||Rec_SnapInfo.end_snap_id||'</TD><TD>'||
              Rec_SnapInfo.end_snap_time||'</TD><TD ALIGN="right">'||ELOG||'</TD><TD ALIGN="right">'||
	      to_char(EOCUR/ELOG,'9,990.00')||'<TD>'||Rec_SnapInfo.end_snap_comment||'</TD></TR>';
    dbms_output.put_line(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="6" ALIGN="center">Elapsed: '||Rec_SnapInfo.elapsed||
              ' min</TD></TR>';
    dbms_output.put_line(L_LINE);
    ELA  := Rec_SnapInfo.ela;
    EBGT := Rec_SnapInfo.ebgt;
    EDRT := Rec_SnapInfo.edrt;
    EET  := Rec_SnapInfo.eet;
    EPC  := Rec_SnapInfo.epc;
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Cache Sizes
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="#cachesizes">Cache Sizes (End)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Size</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD>Buffer Cache</TD><TD ALIGN="right">'||to_char(round(BC/1024/1024),'999,999')||' M</TD></TR>'||
            ' <TR><TD>Std Block Size</TD><TD ALIGN="right">'||to_char(round(BS/1024),'999,999')||' K</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD>Shared Pool Size</TD><TD ALIGN="right">'||to_char(round(SP/1024/1024),'999,999')||' M</TD></TR>'||
            ' <TR><TD>Log Buffer</TD><TD ALIGN="right">'||to_char(round(LB/1024),'999,999')||' K</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Load Profile
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="#loads">Load Profile</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Per Second</TH><TH CLASS="th_sub">Per Transaction</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Redo Size</TD><TD ALIGN="right">'||
            to_char(round(RSIZ/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(RSIZ/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Logical Reads</TD><TD ALIGN="right">'||
            to_char(round(GETS/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(GETS/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Block Changes</TD><TD ALIGN="right">'||
            to_char(round(CHNG/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(CHNG/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Physical Reads</TD><TD ALIGN="right">'||
            to_char(round(PHYR/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PHYR/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Physical Writes</TD><TD ALIGN="right">'||
            to_char(round(PHYW/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PHYW/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">User Calls</TD><TD ALIGN="right">'||
            to_char(round(UCAL/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(UCAL/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Parses</TD><TD ALIGN="right">'||
            to_char(round(PRSE/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PRSE/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Hard Parses</TD><TD ALIGN="right">'||
            to_char(round(HPRS/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(HPRS/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Sorts</TD><TD ALIGN="right">'||
            to_char(round((SRTM+SRTD)/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round((SRTM+SRTD)/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Logons</TD><TD ALIGN="right">'||
            to_char(round(LOGC/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(LOGC/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Executes</TD><TD ALIGN="right">'||
            to_char(round(EXE/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(EXE/TRAN,2),'9,999,990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Transactions</TD><TD ALIGN="right">'||
            to_char(round(TRAN/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">&nbsp;</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Instance Efficiency Percentages
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="#efficiency">Instance Efficiency Percentages (Target: 100%)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Efficiency (%)</TH></TR>';
  dbms_output.put_line(L_LINE);
  IF RENT = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*(1-BFWT/GETS),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Buffer Nowait</TD><TD ALIGN="right">'||
            to_char(round(100*(1-BFWT/GETS),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Redo Nowait</TD><TD ALIGN="right">'||
            S1||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  IF (SRTM+SRTD) = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*SRTM/(SRTD+SRTM),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Buffer Hit</TD><TD ALIGN="right">'||
            to_char(round(100*(1-(PHYR-PHYRD-PHYRDL)/GETS),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>In-Memory Sort</TD><TD ALIGN="right">'||
            S1||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD>Library Hit</TD><TD ALIGN="right">'||
            to_char(round(100*LHTR,2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Soft Parse</TD><TD ALIGN="right">'||
            to_char(round(100*(1-HPRS/PRSE),2),'990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD>Execute to Parse</TD><TD ALIGN="right">'||
            to_char(round(100*(1-PRSE/EXE),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Latch Hit</TD><TD ALIGN="right">'||
            to_char(round(100*(1-LHR),2),'990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  IF PRSELA = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*PRSCPU/PRSELA,2),'990.00');
  END IF;
  IF TCPU = 0
  THEN S2 := '&nbsp;';
  ELSE S2 := to_char(round(100*(1-(PRSCPU/TCPU)),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Parse CPU to Parse Elapsed</TD><TD ALIGN="right">'||
            S1||'</TD></TR>'||
            ' <TR><TD>Non-Parse CPU</TD><TD ALIGN="right">'||
            S2||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Shared Pool Stats
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="#sharedpool">Shared Pool Statistics</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Begin</TH>'||
	    '<TH CLASS="th_sub">End</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Memory Usage %</TD><TD>'||
            to_char(round(100*(1-BFRM/BSPM),2),'990.00')||'</TD><TD>'||
	    to_char(round(100*(1-EFRM/ESPM),2),'990.00')||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SPSQL IN C_SPSQL(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">% SQL with executions &gt; 1</TD><TD>'||
              to_char(round(R_SPSQL.b_single_sql,2),'990.00')||'</TD><TD>'||
	      to_char(round(R_SPSQL.e_single_sql,2),'990.00')||'</TD></TR>';
    dbms_output.put_line(L_LINE);
    L_LINE := ' <TR><TD CLASS="td_name">% Memory for SQL with executions &gt; 1</TD><TD>'||
              to_char(round(R_SPSQL.b_single_mem,2),'990.00')||'</TD><TD>'||
	      to_char(round(R_SPSQL.e_single_mem,2),'990.00')||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Top 5 Wait Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="#top5wait">Top 5 Wait Events</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	    '<TH CLASS="th_sub">Wait Time (s)</TH><TH CLASS="th_sub">% Total Wt Time (ms)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Top5 IN C_Top5(DBID,INST_NUM,BID,EID,TWT) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Top5.event||'</TD><TD ALIGN="right">'||R_Top5.waits||
              '</TD><TD ALIGN="right">'||R_Top5.time||'</TD><TD ALIGN="right">'||R_Top5.pctwtt||
	      '</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- All Wait Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="#waitevents">All Wait Events</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
	    '(desc), Waits (desc); idle events last</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	    '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time (s)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wait Time (ms)</TH><TH CLASS="th_sub">'||
            'Waits/TXN</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_AllWait IN C_AllWait(DBID,INST_NUM,BID,EID,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_AllWait.event||'</TD><TD ALIGN="right">'||
              R_AllWait.waits||'</TD><TD ALIGN="right">'||R_AllWait.timeouts||'</TD><TD ALIGN="right">'||
	      R_AllWait.time||'</TD><TD ALIGN="right">'||R_AllWait.wt||'</TD><TD ALIGN="right">'||
	      R_AllWait.txwaits||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- BG Wait Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="#bgwaitevents">Background Wait Events</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
	    '(desc), Waits (desc); idle events last</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	    '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time (s)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wait Time (ms)</TH><TH CLASS="th_sub">'||
            'Waits/TXN</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_BGWait IN C_BGWait(DBID,INST_NUM,BID,EID,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_BGWait.event||'</TD><TD ALIGN="right">'||
              R_BGWait.waits||'</TD><TD ALIGN="right">'||R_BGWait.timeouts||'</TD><TD ALIGN="right">'||
	      R_BGWait.time||'</TD><TD ALIGN="right">'||R_BGWait.wt||'</TD><TD ALIGN="right">'||
	      R_BGWait.txwaits||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- SQL by Gets
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="#sqlbygets">SQL ordered by Gets</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="7">End Buffer Gets Treshold: '||EBGT||
	    '<P ALIGN="justify" STYLE="margin-top:4">Note that resources reported for PL/SQL includes the ';
  dbms_output.put_LINE(L_LINE);
  L_LINE := 'resources used by all SQL statements called within the PL/SQL code.'||
            ' As individual SQL statements are also reported, it is possible '||
            'and valid for the summed total % to exceed 100.</P></TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Buffer Gets</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">Gets per Exec</TH><TH CLASS="th_sub">% Total</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">CPU Time (s)</TH><TH CLASS="th_sub">'||
            'Elapsed Time (s)</TH><TH CLASS="th_sub">Hash Value</TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SQL IN C_SQLByGets(DBID,INST_NUM,BID,EID,GETS) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.bufgets||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.getsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.pcttotal||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_SQL.cputime||'</TD><TD ALIGN="right">'||R_SQL.elapsed||
              '</TD><TD ALIGN="right">'||R_SQL.hashval||'</TD></TR>'||CHR(10)||
	      ' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    dbms_output.put_line(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := R_Statement.sql_text;
      dbms_output.put_line(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- SQL by Reads
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="#sqlbyreads">SQL ordered by Reads</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="7" ALIGN="center">End Disk Reads Treshold: '||EDRT||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Pysical Reads</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">Reads per Exec</TH><TH CLASS="th_sub">% Total</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">CPU Time (s)</TH><TH CLASS="th_sub">'||
            'Elapsed Time (s)</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SQL IN C_SQLByReads(DBID,INST_NUM,BID,EID,PHYR) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.phyreads||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.readsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.pcttotal||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_SQL.cputime||'</TD><TD ALIGN="right">'||R_SQL.elapsed||
              '</TD><TD ALIGN="right">'||R_SQL.hashval||'</TD></TR>'||CHR(10)||
	      ' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    dbms_output.put_line(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      dbms_output.put_line(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- SQL by Executions
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="#sqlbyexec">SQL ordered by Executions</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">End Executions Treshold: '||EET||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Executions</TH><TH CLASS="th_sub">Rows Processed</TH>'||
	    '<TH CLASS="th_sub">Rows per Exec</TH><TH CLASS="th_sub">CPU per Exec (s)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Elap per Exec (s)</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SQL IN C_SQLByExec(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.execs||'</TD><TD ALIGN="right">'||
              R_SQL.rowsproc||'</TD><TD ALIGN="right">'||R_SQL.rowsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.cputime||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_SQL.elapsed||'</TD><TD ALIGN="right">'||R_SQL.hashval||
              '</TD></TR>'||CHR(10)||' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    dbms_output.put_line(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      dbms_output.put_line(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- SQL by Parse
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="#sqlbyparse">SQL ordered by Parse Calls</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="4" ALIGN="center">End Parse Calls Treshold: '||EPC||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Parse Calls</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">% Total Parses</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SQL IN C_SQLByParse(DBID,INST_NUM,BID,EID,PRSE) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.parses||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.pctparses||
	      '</TD><TD ALIGN="right">'||R_SQL.hashval||
              '</TD></TR>'||CHR(10)||' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    dbms_output.put_line(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      dbms_output.put_line(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Instance Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="#instact">Instance Activity Stats</A></TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Total</TH>'||
	    '<TH CLASS="th_sub">per Second</TH><TH CLASS="th_sub">per TXN</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Inst IN C_InstAct(DBID,INST_NUM,BID,EID,ELA,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Inst.name||'</TD><TD ALIGN="right">'||
              R_Inst.total||'</TD><TD ALIGN="right">'||R_Inst.sec||
	      '</TD><TD ALIGN="right">'||R_Inst.txn||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- TS IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="#tsio">TableSpace IO Summary Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">Ordered by IOs (Reads + Writes) desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Reads</TH>'||
	    '<TH CLASS="th_sub">AvgReads/s</TH><TH CLASS="th_sub">AvgRd (ms)</TH>'||
	    '<TH CLASS="th_sub">Avg Blks/Rd</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Writes</TH><TH CLASS="th_sub">Avg Wrt/s</TH>'||
           '<TH CLASS="th_sub">Buffer Waits</TH><TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_TSIO IN C_TSIO(DBID,INST_NUM,BID,EID,ELA) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right">'||R_TSIO.avgrd||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_TSIO.bpr||'</TD><TD ALIGN="right">'||R_TSIO.writes||
              '</TD><TD ALIGN="right">'||R_TSIO.wps||'</TD><TD ALIGN="right">'||
	      R_TSIO.waits||'</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- File IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="#fileio">File IO Summary Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="10" ALIGN="center">Ordered by TableSpace, File</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Filename</TH>'||
            '<TH CLASS="th_sub">Reads</TH><TH CLASS="th_sub">AvgReads/s</TH>'||
	    '<TH CLASS="th_sub">AvgRd (ms)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Avg Blks/Rd</TH><TH CLASS="th_sub">Writes</TH>'||
           '<TH CLASS="th_sub">Avg Wrt/s</TH><TH CLASS="th_sub">Buffer Waits</TH>'||
	   '<TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_TSIO IN C_FileIO(DBID,INST_NUM,BID,EID,ELA) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD CLASS="td_name">'||
              R_TSIO.filename||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right">'||R_TSIO.avgrd||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_TSIO.bpr||'</TD><TD ALIGN="right">'||R_TSIO.writes||
              '</TD><TD ALIGN="right">'||R_TSIO.wps||'</TD><TD ALIGN="right">'||
	      R_TSIO.waits||'</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Buffer Pool
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="#bufpool">Buffer Pool Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">Standard Block Size Pools ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'D:Default, K:Keep, R:Recycle<BR>Default Pools for other block '||
	    'sizes: 2k, 4k, 8k, 16k, 32k</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub"># of Buffers</TH>'||
            '<TH CLASS="th_sub">Cache Hit %</TH><TH CLASS="th_sub">Buffer Gets</TH>'||
	    '<TH CLASS="th_sub">PhyReads</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">PhyWrites</TH><TH CLASS="th_sub">FreeBuf Waits</TH>'||
           '<TH CLASS="th_sub">Wrt complete Waits</TH><TH CLASS="th_sub">Buffer Busy Waits</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Buff IN C_BuffP(DBID,INST_NUM,BID,EID,BS) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.name||'</TD><TD ALIGN="right">'||
              R_Buff.numbufs||'</TD><TD ALIGN="right">'||
              R_Buff.hitratio||'</TD><TD ALIGN="right">'||R_Buff.gets||
	      '</TD><TD ALIGN="right">'||R_Buff.phread||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_Buff.phwrite||'</TD><TD ALIGN="right">'||R_Buff.fbwait||
              '</TD><TD ALIGN="right">'||R_Buff.wcwait||'</TD><TD ALIGN="right">'||
	      R_Buff.bbwait||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Instance Recovery
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="#recover">Instance Recovery Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Target MTTR (s)</TH>'||
            '<TH CLASS="th_sub">Estd MTTR (s)</TH><TH CLASS="th_sub">Recovery Estd IOs</TH>'||
	    '<TH CLASS="th_sub">Actual Redo Blks</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Target Redo Blks</TH><TH CLASS="th_sub">LogFile Size Redo Blks</TH>'||
           '<TH CLASS="th_sub">Log Ckpt Timeout Redo Blks</TH>'||
	   '<TH CLASS="th_sub">Log Ckpt Interval Redo Blks</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Reco IN C_Recover(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Reco.name||'</TD><TD ALIGN="right">'||
              R_Reco.tm||'</TD><TD ALIGN="right">'||R_Reco.em||
	      '</TD><TD ALIGN="right">'||R_Reco.rei||'</TD><TD ALIGN="right">'||
	      R_Reco.arb||'</TD><TD ALIGN="right">';
    dbms_output.put_line(L_LINE);
    L_LINE := R_Reco.trb||'</TD><TD ALIGN="right">'||R_Reco.lfrb||
              '</TD><TD ALIGN="right">'||R_Reco.lctrb||'</TD><TD ALIGN="right">'||
	      R_Reco.lcirb||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Buffer Waits
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="#bufwait">Buffer Wait Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="4" ALIGN="center">Ordered by Wait Time desc, Waits desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Class</TH><TH CLASS="th_sub">Waits</TH>'||
            '<TH CLASS="th_sub">Tot Wait Time (s)</TH>'||
	    '<TH CLASS="th_sub">Avg Wait Time (s)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Buff IN C_BuffW(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.class||'</TD><TD ALIGN="right">'||
              R_Buff.icnt||'</TD><TD ALIGN="right">'||R_Buff.itim||
	      '</TD><TD ALIGN="right">'||R_Buff.iavg||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- PGA Aggreg Target Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="#pga">PGA Aggreg Target Memory Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">PGA Aggreg Target (M)</TH>'||
            '<TH CLASS="th_sub">PGA in Use (M)</TH><TH CLASS="th_sub">W/A PGA in Use (M)</TH>'||
	    '<TH CLASS="th_sub">1-Pass Mem Req (M)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">% Optim W/A Execs</TH><TH CLASS="th_sub">% Non-W/A PGA Memory</TH>'||
           '<TH CLASS="th_sub">% Auto W/A PGA Mem</TH>'||
	   '<TH CLASS="th_sub">% Manual W/A PGA Mem</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_PGAA IN C_PGAA(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAA.snap||'</TD><TD ALIGN="right">'||
              R_PGAA.pgaat||'</TD><TD ALIGN="right">'||R_PGAA.tot_pga_used||
	      '</TD><TD ALIGN="right">'||R_PGAA.tot_tun_used;
    dbms_output.put_line(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||R_PGAA.onepr||'</TD><TD ALIGN="right"'||
              R_PGAA.opt_pct||'</TD><TD ALIGN="right">'||R_PGAA.pct_unt||
	      '</TD><TD ALIGN="right">'||R_PGAA.pct_auto_tun||
	      '</TD><TD ALIGN="right">'||R_PGAA.pct_man_tun||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');


  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  dbms_output.put_line(L_LINE);
  L_LINE := '<TR><TD><FONT SIZE="-2">Created by OSPRep v$version &copy; 2003 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></FONT></TD></TR>';
  dbms_output.put_line(L_LINE);
  dbms_output.put_line(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  dbms_output.put_line(L_LINE);

END;
/

SPOOL off

EOF
