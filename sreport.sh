#!/bin/bash
# $Id$
#
# =============================================================================
# StatsPack Report 2 Html              (c) 2003 by IzzySoft (devel@izzysoft.de)     
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
version='0.0.3'
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "StatsRep v$version              (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
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
  L_LINE VARCHAR(4000);
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
  BID NUMBER; EID NUMBER; ELA NUMBER;
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
	   (e.snap_time - b.snap_time)*1440*60 ela
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
  L_LINE := TABLE_OPEN||'<TR><TD><FONT SIZE=-2>[ <A HREF="#snapinfo">SnapShot Info</A> ] '||
            '[ <A HREF="#cachesizes">Cache Sizes</A> ] [ <A HREF="#loads">Load Profile</A> '||
            '] [ <A HREF="#efficiency">Efficiency</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE :=   ' [ <A HREF="#sharedpool">Shared Pool</A> ] [ <A HREF="#top5wait">Top 5 Wait</A>'||
            ' ] [ <A HREF="#waitevents">Wait Events</A> ] [ <A HREF="#bgwaitevents">Background Waits</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#events">Events</A> ] [ <A HREF="#invobj">Invalid Objects</A> ]'||
	    ' [ <A HREF="#misc">Misc</A> ]</TD></TR>';
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
    ELA := Rec_SnapInfo.ela;
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


  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  dbms_output.put_line(L_LINE);
  L_LINE := '<TR><TD><FONT SIZE="-2">Created by StatsRep v$version &copy; 2003 by '||
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
