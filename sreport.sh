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
version='0.0.7'
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
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [StartID EndID]"
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

#--- SnapShot Interval. Set values to 0 for automatic evaluation of latest
#--- continuous interval (i.e. the interval ending with the latest recording
#--- SnapShot and starting with the first SnapShot having the same database
#--- startup time)
#--- You may set both values to 0 (last interval will be used then), both to
#--- a value > 0 (specified value is used), or START_ID=0 and END_ID>0. In
#--- all cases, only specify existing SnapShot IDs.
#--- Arguments on the command line override these settings.
START_ID=0
END_ID=203

# If Start/End ID are specified on CmdLine, override internal settings:
if [ -n "$2" ]; then
  START_ID=$2
fi
if [ -n "$3" ]; then
  END_ID=$3
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
  EPC NUMBER; BTIME VARCHAR2(20); ETIME VARCHAR2(20);
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

  CURSOR C_MaxSnap(db_id IN NUMBER, instnum IN NUMBER) IS
    SELECT MAX(snap_id) maxid FROM stats\$snapshot
     WHERE dbid = db_id AND instance_number = instnum;

  CURSOR C_MinSnap(db_id IN NUMBER, instnum IN NUMBER, maxsnap IN NUMBER) IS
    SELECT MIN(snap_id) minid FROM stats\$snapshot
     WHERE dbid = db_id AND instance_number = instnum
       AND startup_time = (SELECT startup_time FROM stats\$snapshot
                            WHERE dbid = db_id AND instance_number = instnum
			      AND snap_id = maxsnap);
  
  CURSOR C_SnapBind (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER) IS
    SELECT parallel,version,host_name
      FROM stats\$database_instance di,stats\$snapshot s
     WHERE s.snap_id=bid AND s.dbid=db_id AND s.instance_number=instnum
       AND di.dbid=s.dbid AND di.instance_number=s.instance_number
       AND di.startup_time=s.startup_time;

  CURSOR C_SnapInfo (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.snap_id begin_snap_id,to_char(b.snap_time,'dd.mm.yyyy hh24:mi') begin_snap_time,
           NVL(b.ucomment,'&nbsp;') begin_snap_comment,
	   e.snap_id end_snap_id,to_char(e.snap_time,'dd.mm.yyyy hh24:mi') end_snap_time,
	   NVL(e.ucomment,'&nbsp;') end_snap_comment,
	   to_char(round(((e.snap_time - b.snap_time) * 1440 * 60),0)/60,'9,999,990.00') elapsed,
	   (e.snap_time - b.snap_time)*1440*60 ela,
	   e.buffer_gets_th ebgt,
	   e.disk_reads_th edrt,
	   e.executions_th eet,
	   e.parse_calls_th epc
      FROM stats\$snapshot b, stats\$snapshot e
     WHERE b.snap_id=bid
       AND e.snap_id=eid
       AND b.dbid=db_id
       AND e.dbid=db_id
       AND b.instance_number=instnum
       AND e.instance_number=instnum
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
	   nvl(to_char(s.opt_pct,'990.00'),'&nbsp;')           opt_pct,
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
	   nvl(to_char(s.opt_pct,'990.00'),'&nbsp;')           opt_pct,
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

  CURSOR C_PGAM (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.name st,
           to_char(b.value/1024/1024,'9,999,990.00') snap1,
           to_char(e.value/1024/1024,'9,999,990.00') snap2,
	   to_char(decode(b.value,0,100* (e.value - nvl(b.value,0)),
	                            100*((e.value - nvl(b.value,0))/b.value)),
		   '990.00') diff
      FROM stats\$pgastat b, stats\$pgastat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.name    = e.name
       AND e.value  >= b.value
       AND e.value  >  0
    UNION SELECT b.name st,
           to_char(b.value/1024/1024,'9,999,990.00') snap1,
           to_char(e.value/1024/1024,'9,999,990.00') snap2,
	   to_char(decode(b.value,0,100* (e.value - nvl(b.value,0)),
	                            100*((e.value - nvl(b.value,0))/b.value)),
		   '990.00') diff
      FROM stats\$sysstat b, stats\$sysstat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.name    = e.name
       AND e.name    = 'workarea memory allocated'
       AND e.value  >= b.value
       AND e.value  >  0;

  CURSOR C_Enq (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT e.eq_type name,
           to_char(e.total_req# - nvl(b.total_req#,0),'99,999,999') reqs,
	   to_char(e.succ_req#  - nvl(b.succ_req#,0),'99,999,999') sreq,
	   to_char(e.failed_req# - nvl(b.failed_req#,0),'99,999,999') freq,
	   to_char(e.total_wait# - nvl(b.total_wait#,0),'999,999') waits,
	   to_char(decode( (e.total_wait# - nvl(b.total_wait#,0)),
	                   0, to_number(NULL),
			   (  (e.cum_wait_time - nvl(b.cum_wait_time,0))
			    / (e.total_wait# - nvl(b.total_wait#,0))
			   ) ),'999,999,990.00') awttm,
	   to_char((e.cum_wait_time - nvl(b.cum_wait_time,0))/1000,
	            '999,999') wttm
      FROM stats\$enqueue_stat b, stats\$enqueue_stat e
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.eq_type(+) = e.eq_type
       AND e.total_wait# - nvl(b.total_wait#,0) > 0
     ORDER BY waits desc, reqs desc;

  CURSOR C_RBS (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.usn rbs#,
           to_char(e.gets - b.gets,'999,990.0') gets,
	   to_char(to_number(decode(e.gets,b.gets,NULL,
	          (e.waits - b.waits) * 100 / (e.gets - b.gets) )),
		  '990.00') waits,
	   to_char(e.writes - b.writes,'999,999,999,990') writes,
	   to_char(e.wraps - b.wraps,'999,999') wraps,
	   to_char(e.shrinks - b.shrinks,'999,999') shrinks,
	   to_char(e.extends - b.extends,'999,999') extends
      FROM stats\$rollstat b, stats\$rollstat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND e.usn     = b.usn
     ORDER BY e.usn;

  CURSOR C_RBST (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.usn rbs#,
           to_char(e.rssize,'99,999,999,999') rssize,
	   to_char(e.aveactive,'999,999,999') active,
	   nvl(to_char(to_number(decode(e.optsize,-4096,NULL,e.optsize)),
	           '99,999,999,999'),'&nbsp;') optsize,
	   to_char(e.hwmsize,'99,999,999,999') hwmsize
      FROM stats\$rollstat b, stats\$rollstat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND e.usn     = b.usn
     ORDER BY e.usn;

  CURSOR C_USS (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, btime IN VARCHAR2, etime IN VARCHAR2) IS
    SELECT undotsn,
           to_char(sum(undoblks),'99,999,999') undob,
	   to_char(sum(txncount),'99,999,999') txcnt,
	   to_char(max(maxquerylen),'999,999,999') maxq,
	   to_char(max(maxconcurrency),'999,999') maxc,
	   to_char(sum(ssolderrcnt),'99,999') snol,
	   to_char(sum(nospaceerrcnt),'99,999') nosp,
	   sum(unxpstealcnt)||'/'||sum(unxpblkrelcnt)||'/'||
	   sum(unxpblkreucnt)||' / '||sum(expstealcnt)||'/'||
	   sum(expblkrelcnt)||'/'||sum(expblkreucnt) blkst
      FROM stats\$undostat
     WHERE dbid = db_id
       AND instance_number = instnum
       AND end_time > to_date(btime, 'DD.MM.YYYY HH24:MI:SS')
       AND begin_time < to_date(etime, 'DD.MM.YYYY HH24:MI:SS')
     GROUP BY undotsn;

  CURSOR C_UST (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, btime IN VARCHAR2, etime IN VARCHAR2) IS
    SELECT undotsn, endt,undob,txcnt,maxq,maxc,snol,nosp,blkst
    FROM ( SELECT undotsn,
                to_char(end_time,'DD.MM.YYYY HH24:MI') endt,
                to_char(undoblks,'99,999,999') undob,
                to_char(txncount,'99,999,999') txcnt,
	        to_char(maxquerylen,'999,999,999') maxq,
	        to_char(maxconcurrency,'999,999') maxc,
	        to_char(ssolderrcnt,'99,999') snol,
	        to_char(nospaceerrcnt,'99,999') nosp,
	        unxpstealcnt||'/'||unxpblkrelcnt||'/'||
	        unxpblkreucnt||' / '||expstealcnt||'/'||
	        expblkrelcnt||'/'||expblkreucnt blkst
           FROM stats\$undostat
          WHERE dbid = db_id
            AND instance_number = instnum
            AND end_time > to_date(btime, 'DD.MM.YYYY HH24:MI:SS')
            AND begin_time < to_date(etime, 'DD.MM.YYYY HH24:MI:SS')
       ORDER BY begin_time desc )
   WHERE rownum < 25;

  CURSOR C_LAA (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.name name,
           to_char(e.gets - b.gets,'99,999,999,999') gets,
	   nvl(to_char(decode(e.gets, b.gets, NULL,
	                  (e.misses - b.misses) * 100 /
			  (e.gets - b.gets)),'990.00'),'&nbsp;') missed,
	   nvl(to_char(decode(e.misses, b.misses, NULL,
	                  (e.sleeps - b.sleeps) /
			  (e.misses - b.misses)),'990.00'),'&nbsp;') sleeps,
	   to_char((e.wait_time - b.wait_time)/1000000,'99,999') wt,
	   to_char(e.immediate_gets - b.immediate_gets,'99,999,999,999') nowai,
	   nvl(to_char(decode(e.immediate_gets, b.immediate_gets, NULL,
	                  (e.immediate_misses - b.immediate_misses) *100 /
			  (e.immediate_gets - b.immediate_gets)),'990.00'),
		'&nbsp;') imiss
      FROM stats\$latch b, stats\$latch e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.name    = e.name
       AND (  e.gets - b.gets
            + e.immediate_gets - b.immediate_gets ) > 0
     ORDER BY wt,sleeps,imiss;

  CURSOR C_LAS (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.name name,
           to_char(e.gets - b.gets,'99,999,999,999') gets,
	   to_char(e.misses - b.misses,'99,999,999') misses,
	   to_char(e.sleeps - b.sleeps,'999,999,999') sleeps,
	   to_char(e.spin_gets - b.spin_gets)||'/'||
	   to_char(e.sleep1 - b.sleep1)||'/'||
	   to_char(e.sleep2 - b.sleep2)||'/'||
	   to_char(e.sleep3 - b.sleep3)||'/'||
	   to_char(e.sleep4 - b.sleep4) sleep4
      FROM stats\$latch b, stats\$latch e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.name    = e.name
       AND e.sleeps - b.sleeps > 0
     ORDER BY misses desc;

  CURSOR C_LAM (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT e.parent_name parent,
           e.where_in_code where_from,
	   to_char(e.nwfail_count - nvl(b.nwfail_count,0),'99,999') nwmisses,
	   to_char(e.sleep_count - nvl(b.sleep_count,0),'9,999,999') sleeps,
	   to_char(e.wtr_slp_count - nvl(b.wtr_slp_count,0),'9,999,999') waiter_sleeps
      FROM stats\$latch_misses_summary b, stats\$latch_misses_summary  e
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.dbid(+)    = e.dbid
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.instance_number(+) = e.instance_number
       AND b.parent_name(+)     = e.parent_name
       AND b.where_in_code(+)   = e.where_in_code
       AND e.sleep_count > nvl(b.sleep_count,0)
     ORDER BY e.parent_name, sleeps desc;

  CURSOR C_CAD (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT lower(b.parameter) param,
           to_char(e.gets - b.gets,'9,999,999,990') gets,
	   nvl(to_char(decode(e.gets, b.gets, NULL,
	                (e.getmisses - b.getmisses) *100 /
			(e.gets - b.gets)),'990.00'),'&nbsp') getm,
	   to_char(e.scans - b.scans,'9,990') scans,
	   nvl(to_char(decode(e.scans, b.scans, NULL,
	                (e.scanmisses - b.scanmisses) *100 /
			(e.scans - b.scans)),'990.00'),'&nbsp;') scanm,
	   to_char(e.modifications - b.modifications,'999,990') mods,
	   to_char(e.usage,'9,999,990') usage,
	   to_char(e.usage *100/e.total_usage,'990.00') sgapct
      FROM stats\$rowcache_summary b, stats\$rowcache_summary e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.parameter       = e.parameter
       AND e.gets - b.gets   > 0
     ORDER BY param;

  CURSOR C_CAM (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT b.namespace namespace,
           to_char(e.gets - b.gets,'999,999,990') gets,
	   nvl(to_char(decode(e.gets,b.gets,NULL,
	                100 - (e.gethits - b.gethits) * 100 /
			(e.gets - b.gets)),'990.00'),'&nbsp;') getm,
	   to_char(e.pins - b.pins,'9,999,999,990') pins,
	   nvl(to_char(decode(e.pins,b.pins,NULL,
	                100 - (e.pinhits - b.pinhits) *100 /
			(e.pins - b.pins)),'990.00'),'&nbsp;') pinm,
	   to_char(e.reloads - b.reloads,'9,999,990') reloads,
	   to_char(e.invalidations - b.invalidations,'999,990') inv
      FROM stats\$librarycache b, stats\$librarycache e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.namespace       = e.namespace
       AND e.gets - b.gets   > 0
     ORDER BY namespace;

  CURSOR C_SGASum (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT name,
           to_char(value,'999,999,999,990') val,
	   value rawval
      FROM stats\$sga
     WHERE snap_id = eid
       AND dbid    = db_id
       AND instance_number = instnum
     ORDER BY name;

  CURSOR C_SGABreak (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT nvl(replace(b.pool,'pool',''),'&nbsp;') pool,
           b.name name,
	   to_char(b.bytes,'999,999,999,999') snap1,
	   to_char(e.bytes,'999,999,999,999') snap2,
	   to_char(100* (e.bytes - b.bytes)/b.bytes,'990.00') diff
      FROM stats\$sgastat b, stats\$sgastat e
     WHERE b.snap_id = bid
       AND e.snap_id = eid
       AND b.dbid    = db_id
       AND e.dbid    = db_id
       AND b.dbid    = e.dbid
       AND b.instance_number = instnum
       AND e.instance_number = instnum
       AND b.instance_number = e.instance_number
       AND b.name    = e.name
       AND nvl(b.pool,'a')   = nvl(e.pool,'a')
     ORDER BY b.pool, b.name;

  CURSOR C_RLim (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT resource_name rname,
           to_char(current_utilization,'999,999,990') curu,
           to_char(max_utilization,'999,999,990') maxu,
           to_char(initial_allocation,'999,999,990') inita,
           to_char(limit_value,'999,999,990') lim
      FROM stats\$resource_limit
     WHERE snap_id = eid
       AND dbid    = db_id
       AND instance_number = instnum
       AND (   nvl(current_utilization,0)/limit_value > .8
            or nvl(max_utilization,0)/limit_value > .8 )
     ORDER BY rname;

  CURSOR C_IParm (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
    SELECT e.name,
           nvl(b.value,'&nbsp;') bval,
	   decode(b.value,e.value,'&nbsp;',e.value) eval
      FROM stats\$parameter b, stats\$parameter e
     WHERE b.snap_id(+) = bid
       AND e.snap_id    = eid
       AND b.dbid(+)    = db_id
       AND e.dbid       = db_id
       AND b.instance_number(+) = instnum
       AND e.instance_number    = instnum
       AND b.name(+)    = e.name
       AND (   nvl(b.isdefault,'X')   = 'FALSE'
            or nvl(b.ismodified,'X') != 'FALSE'
	    or     e.ismodified      != 'FALSE'
	    or nvl(e.value,0)        != nvl(b.value,0) );


BEGIN
  -- Configuration
  dbms_output.enable(1000000);
  R_TITLE := 'StatsPack Report for $ORACLE_SID';
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  SELECT d.dbid,d.name,i.instance_number,i.instance_name
    INTO DBID,DB_NAME,INST_NUM,INST_NAME
    FROM v\$database d,v\$instance i;

  IF NVL($END_ID,0) = 0
    THEN
      FOR R_SnapID IN C_MaxSnap(DBID,INST_NUM) LOOP
      EID := R_SnapID.maxid;
    END LOOP;
  ELSE
    EID := $END_ID;
  END IF;
  IF NVL($START_ID,0) = 0
  THEN
    FOR R_SnapID IN C_MinSnap(DBID,INST_NUM,EID) LOOP
      BID := R_SnapID.minid;
    END LOOP;
  ELSE
    BID := $START_ID;
  END IF;

  FOR R_SnapBind IN C_SnapBind(DBID,INST_NUM,BID) LOOP
    PARA  := R_SnapBind.parallel;
    VERSN := R_SnapBind.version;
    HOST_NAME := R_SnapBind.host_name;
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
  L_LINE := ' [ <A HREF="#pga">Memory Stats</A> ] [ <A HREF="#enq">Enqueue Activity</A> ]'||
            ' [ <A HREF="#rbs">RBS</A> ] [ <A HREF="#undo">Undo Segs</A> ]'||
	    ' [ <A HREF="#latches">Latches</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#caches">Caches</A> ] [ <A HREF="#sga">SGA</A> ]'||
            ' [ <A HREF="#resourcelimits">Resource Limits</A> ]'||
	    ' [ <A HREF="#initora">Init Params</A> ]</TD></TR>';
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="snapinfo">SnapShot Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Snap ID</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TH CLASS="th_sub">Snap Time</TH><TH CLASS="th_sub">Sessions</TH>'||
            '<TH CLASS="th_sub">Curs/Sess</TH><TH CLASS="th_sub">Comment</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_SnapInfo IN C_SnapInfo(DBID,INST_NUM,BID,EID) LOOP
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
    BTIME:= Rec_SnapInfo.begin_snap_time;
    ETIME:= Rec_SnapInfo.end_snap_time;
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Cache Sizes
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="cachesizes">Cache Sizes (End)</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="loads">Load Profile</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="efficiency">Instance Efficiency Percentages (Target: 100%)</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sharedpool">Shared Pool Statistics</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="top5wait">Top 5 Wait Events</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="waitevents">All Wait Events</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="sqlbygets">Top $TOP_N_SQL SQL ordered by Gets</A></TH></TR>'||
            CHR(10)||' <TR><TD COLSPAN="7" ALIGN="center">End Buffer Gets Treshold: '||EBGT;
  dbms_output.put_LINE(L_LINE);
  L_LINE := '<P ALIGN="justify" STYLE="margin-top:4">Note that resources reported for PL/SQL includes the '||
            'resources used by all SQL statements called within the PL/SQL code.'||
            ' As individual SQL statements are also reported, ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'it is possible and valid for the summed total % to exceed 100.</P></TD></TR>'||
  CHR(10)||
            ' <TR><TH CLASS="th_sub">Buffer Gets</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">Gets per Exec</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">% Total</TH><TH CLASS="th_sub">CPU Time (s)</TH>'||
            '<TH CLASS="th_sub">Elapsed Time (s)</TH><TH CLASS="th_sub">Hash Value</TR>';
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="sqlbyreads">Top $TOP_N_SQL SQL ordered by Reads</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="sqlbyexec">Top $TOP_N_SQL SQL ordered by Executions</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="sqlbyparse">Top $TOP_N_SQL SQL ordered by Parse Calls</A></TH></TR>'||CHR(10)||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="instact">Instance Activity Stats</A></TH></TR>';
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="tsio">TableSpace IO Summary Statistics</A></TH></TR>'||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="fileio">File IO Summary Statistics</A></TH></TR>'||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="bufpool">Buffer Pool Statistics</A></TH></TR>'||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="recover">Instance Recovery Statistics</A></TH></TR>'||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="bufwait">Buffer Wait Statistics</A></TH></TR>'||
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="pga">PGA Aggreg Target Memory Statistics</A></TH></TR>'||
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

  -- PGA Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4">PGA Memory Statistics</TH></TR>'||
            ' <TR><TD COLSPAN="4" ALIGN="center">WorkArea (W/A) memory is used for: sort, bitmap merge, and hash join ops</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Begin (M)</TH>'||
            '<TH CLASS="th_sub">End (M)</TH><TH CLASS="th_sub">% Diff</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_PGAM IN C_PGAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAM.st||'</TD><TD ALIGN="right">'||
              R_PGAM.snap1||'</TD><TD ALIGN="right">'||R_PGAM.snap2||
	      '</TD><TD ALIGN="right">'||R_PGAM.diff||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Enqueue Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="enq">Enqueue Activity</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">Enqueue Stats gathered prior to 9i '||
	    'should not be compared with 9i data<BR>Ordered by Waits desc, Requests desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Eq</TH><TH CLASS="th_sub">Requests</TH>'||
            '<TH CLASS="th_sub">Succ Gets</TH><TH CLASS="th_sub">Failed Gets</TH>'||
	    '<TH CLASS="th_sub">Waits</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wt Time (ms)</TH><TH CLASS="th_sub">'||
            'Wait Time (s)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_Enq IN C_Enq(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Enq.name||'</TD><TD ALIGN="right">'||
              R_Enq.reqs||'</TD><TD ALIGN="right">'||R_Enq.sreq||
	      '</TD><TD ALIGN="right">'||R_Enq.freq||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_Enq.waits||'</TD><TD ALIGN="right">'||
              R_Enq.awttm||'</TD><TD ALIGN="right">'||R_Enq.wttm||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- RBS Stats
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="#rbs">Rollback Segments Stats</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">A high value for "Pct Waits" '||
	    'suggests more rollback segments may be required<BR>RBS stats may ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'not be accurate between begin and end snaps when using Auto Undo '||
            'Management, as RBS may be dynamically created and dropped as needed</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">RBS#</TH><TH CLASS="th_sub">Trans Table Gets</TH>'||
            '<TH CLASS="th_sub">Pct Waits</TH><TH CLASS="th_sub">Undo Bytes Written</TH>'||
	    '<TH CLASS="th_sub">Wraps</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Shrinks</TH><TH CLASS="th_sub">'||
            'Extends</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_RBS IN C_RBS(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
              R_RBS.gets||'</TD><TD ALIGN="right">'||R_RBS.waits||
	      '</TD><TD ALIGN="right">'||R_RBS.writes||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_RBS.wraps||'</TD><TD ALIGN="right">'||
              R_RBS.shrinks||'</TD><TD ALIGN="right">'||R_RBS.extends||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- RBS Storage
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Rollback Segments Storage</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Optimal Size should be larger '||
	    'than Avg Active</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">RBS#</TH><TH CLASS="th_sub">Segment Size</TH>'||
            '<TH CLASS="th_sub">Avg Active</TH><TH CLASS="th_sub">Optimal Size</TH>'||
	    '<TH CLASS="th_sub">Maximum Size</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_RBS IN C_RBST(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
              R_RBS.rssize||'</TD><TD ALIGN="right">'||R_RBS.active||
	      '</TD><TD ALIGN="right">'||R_RBS.optsize||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_RBS.hwmsize||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Undo Segs Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="undo">Undo Segment Summary</A></TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">Undo Segment block stats<BR>'||
	    'uS - unexpired Stolen, uR - unexpired Released, uU - unexpired reUsed<BR>';
  dbms_output.put_line(L_LINE);
  L_LINE := 'eS - expired Stolen, eR - expired Released, eU - expired reUsed</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Undo TS#</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
            '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	    '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
            'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_USS IN C_USS(DBID,INST_NUM,BID,EID,BTIME,ETIME) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.undotsn||'</TD><TD ALIGN="right">'||
              R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	      '</TD><TD ALIGN="right">'||R_USS.maxq||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
              R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	      R_USS.blkst||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Undo Segs Stat
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Undo Segment Statistics</TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">Ordered by Time desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">End Time</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
            '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	    '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
            'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_USS IN C_UST(DBID,INST_NUM,BID,EID,BTIME,ETIME) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.endt||'</TD><TD ALIGN="right">'||
              R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	      '</TD><TD ALIGN="right">'||R_USS.maxq||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
              R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	      R_USS.blkst||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Latch Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="latches">Latch Activity</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">"Get Requests", "Pct Get Miss"'||
	    ' and "Avg Slps/Miss" are statistics for willing-to-wait';
  dbms_output.put_line(L_LINE);
  L_LINE := ' latch get requests<BR>"NoWait Requests", "Pct NoWait Miss" are '||
            'for no-wait latch get requests<BR>"Pct Misses" for both should be '||
	    'very close to 0.0<BR>';
  dbms_output.put_line(L_LINE);
  L_LINE := 'Ordered by Wait Time desc, Avg Slps/Miss, Pct NoWait Miss desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Get Miss</TH><TH CLASS="th_sub">Avg Slps/Miss</TH>'||
	    '<TH CLASS="th_sub">Wait Time (s)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">NoWait Requests</TH><TH CLASS="th_sub">'||
            'Pct NoWait Miss</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_LA IN C_LAA(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
              R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.missed||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_LA.wt||'</TD><TD ALIGN="right">'||
              R_LA.nowai||'</TD><TD ALIGN="right">'||R_LA.imiss||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Latch Sleep Breakdown
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Latch Sleep Breakdown</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Ordered by Misses desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Misses</TH><TH CLASS="th_sub">Sleeps</TH>'||
	    '<TH CLASS="th_sub">Spin & Sleeps 1-&gt;4</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_LA IN C_LAS(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
              R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.misses||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="center">'||R_LA.sleep4||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Latch Miss Sources
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Latch Miss Sources</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Only Latches with Sleeps are '||
	    'shown<BR>Ordered by Name, Sleeps desc</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Where</TH>'||
            '<TH CLASS="th_sub">NoWait Misses</TH><TH CLASS="th_sub">Sleeps</TH>'||
	    '<TH CLASS="th_sub">Waiter Sleeps</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_LA IN C_LAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.parent||'</TD><TD>'||
              R_LA.where_from||'</TD><TD ALIGN="right">'||R_LA.nwmisses||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_LA.waiter_sleeps||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Dictionary Cache
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="caches">Dictionary Cache</A></TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">"Pct Misses" should be very '||
	    ' low (&lt; 2% in most cases)<BR>';
  dbms_output.put_line(L_LINE);
  L_LINE := '"Cache Usage" is the number of cache entries being used<BR>'||
            '"Pct SGA" is the ratio of usage to allocated size for that cache</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Miss</TH><TH CLASS="th_sub">Scan Reqs</TH>'||
	    '<TH CLASS="th_sub">Pct Miss</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Mod Reqs</TH><TH CLASS="th_sub">Final Usage</TH>'||
            '<TH CLASS="th_sub">Pct SGA</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_CA IN C_CAD(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_CA.param||'</TD><TD ALIGN="right">'||
              R_CA.gets||'</TD><TD ALIGN="right">'||R_CA.getm||
	      '</TD><TD ALIGN="right">'||R_CA.scans||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_CA.scanm||'</TD><TD ALIGN="right">'||
              R_CA.mods||'</TD><TD ALIGN="right">'||R_CA.usage||
	      '</TD><TD ALIGN="right">'||R_CA.sgapct||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Library Cache
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7">Library Cache</TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">"Pct Misses" should be very low</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">NameSpace</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Miss</TH><TH CLASS="th_sub">Pin Reqs</TH>'||
	    '<TH CLASS="th_sub">Pct Miss</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Reloads</TH><TH CLASS="th_sub">Invalidations</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_CA IN C_CAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_CA.namespace||'</TD><TD ALIGN="right">'||
              R_CA.gets||'</TD><TD ALIGN="right">'||R_CA.getm||
	      '</TD><TD ALIGN="right">'||R_CA.pins||'</TD>';
    dbms_output.put_line(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_CA.pinm||'</TD><TD ALIGN="right">'||
              R_CA.reloads||'</TD><TD ALIGN="right">'||R_CA.inv||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- SGA Memory Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="sga">SGA Memory Summary</A></TH></TR>'||
            ' <TR><TD COLSPAN="2" ALIGN="center">Values at the time of the End SnapShot</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">SGA Region</TH><TH CLASS="th_sub">Size in Bytes</TH>';
  dbms_output.put_line(L_LINE);
  I1 := 0;
  FOR R_SGASum in C_SGASum(DBID,INST_NUM,BID,EID) LOOP
    I1 := I1 + R_SGASum.rawval;
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.name||'</TD><TD ALIGN="right">'||
              R_SGASum.val||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD>Sum</TD><TD ALIGN="right">'||to_char(I1,'999,999,999,990')||
            '</TD></TR>'||TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- SGA breakdown diff
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">SGA BreakDown Difference</TH></TR>'||
            ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Name</TH>'||
	    '<TH CLASS="th_sub">Begin Value</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">End Value</TH><TH CLASS="th_sub">% Diff</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_SGASum in C_SGABreak(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.pool||'</TD><TD CLASS="td_name">'||
              R_SGASum.name||'</TD><TD ALIGN="right">'||R_SGASum.snap1||
	      '</TD><TD ALIGN="right">'||R_SGASum.snap2||'</TD><TD ALIGN="right">'||
	      R_SGASum.diff||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Resource Limits
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="resourcelimits">Resource Limits</A></TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">"Current" is the time of the End SnapShot</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Resource</TH><TH CLASS="th_sub">Curr Utilization</TH>'||
	    '<TH CLASS="th_sub">Max Utilization</TH><TH CLASS="th_sub">'||
	    'Init Allocation</TH><TH CLASS="th_sub">Limit</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_RLim in C_RLim(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_RLim.rname||'</TD><TD ALIGN="right">'||
              R_RLim.curu||'</TD><TD ALIGN="right">'||R_RLim.maxu||
	      '</TD><TD ALIGN="right">'||R_RLim.inita||'</TD><TD ALIGN="right">'||
	      R_RLim.lim||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Init.Ora Params
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="initora">Initialization Parameters (init.ora)</A></TH></TR>'||
            ' <TR><TH CLASS="th_sub">Parameter Name</TH><TH CLASS="th_sub">Begin Value</TH>'||
	    '<TH CLASS="th_sub">End Value (if different)</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR R_IParm in C_IParm(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_IParm.name||'</TD><TD>'||
              R_IParm.bval||'</TD><TD>'||R_IParm.eval||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);


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
