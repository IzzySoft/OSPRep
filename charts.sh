#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html  (c) 2003-2004 by IzzySoft (devel@izzysoft.de)     
# -----------------------------------------------------------------------------
# Chart Generator
# -----------------------------------------------------------------------------
# Retrieves all necessary information to create charts and writes the HTML
# and JavaScript files for this
#                                                              Itzchak Rehberg
# =============================================================================
#
. ./version
# =======================================================[ Header / Syntax ]===
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OSPRep v$version                (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
  echo ----------------------------------------------------------------------------
  echo This script is intended to retrieve the execution plans for all statements
  echo that caused Full Table Scans, using the statistics gathered by the Oracle
  echo StatsPack. Look inside the script header for closer details, and
  echo check for the configuration in the separate 'config' file.
  echo ----------------------------------------------------------------------------
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [Options]"
  echo "  Options:"
  echo "     -c <ConfigFileName>"
  echo "     -b <BEGIN_ID (Snapshot)"
  echo "     -e <END_ID (Snapshot)>"
  echo "     -p <Password>"
  echo "     -s <ORACLE_SID/Connection String for Target DB>"
  echo "     -u <username>"
  echo "  Example: generate report for oradb up to snapshot ID 1800:"
  echo "   ${SCRIPT} oradb -e 1800"
  echo ============================================================================
  echo
  exit 1
fi

# =================================================[ Configuration Section ]===
#BINDIR=${0%/*}
BINDIR=`pwd`
CONFIG=$BINDIR/config
ARGS=$*
# ------------------------------------------[ process command line options ]---
while [ "$1" != "" ] ; do
  case "$1" in
    -s) shift; ORACLE_CONNECT=$1;;
    -u) shift; user=$1;;
    -p) shift; password=$1;;
    -e) shift; PEND_ID=$1;;
    -b) shift; PSTART_ID=$1;;
    -c) shift; CONFIG=$1;;
  esac
  shift
done

# -------------------------------------------[ Read the Configuration File ]---
. $CONFIG $ARGS
if [ -z "$ORACLE_CONNECT" ]; then
  ORACLE_CONNECT=$ORACLE_SID
fi
if [ -n "$PEND_ID" ]; then END_ID=$PEND_ID; fi
if [ -n "$PSTART_ID" ]; then START_ID=$PSTART_ID; fi
if [ -n "$START_ID" ]; then
  if [ -z "$END_ID" ]; then
    END_ID=$START_ID
  fi
fi

SQLSET=$TMPDIR/osprep_charts_$ORACLE_SID.$$

# ------------------------------------[ Create the FrameSet (control) page ]---
cat >$REPDIR/${ORACLE_SID}_chart.html<<ENDTXT
<HTML><HEAD>
 <TITLE>DBStats for ${ORACLE_SID}</TITLE>
 <SCRIPT LANGUAGE="JavaScript" SRC="${ORACLE_SID}_chart.js"></SCRIPT>
 <SCRIPT LANGUAGE="JavaScript">//<!--
   var dstat = enq;
   var dname = "Enqueues";
   var sid   = "${ORACLE_SID}";
   var vers  = "${version}";
 //--></SCRIPT>
</HEAD>
<FRAMESET COLS="70,*" BORDER="0">
 <FRAME SRC="inc/nav.html" NAME="menu">
 <FRAME SRC="inc/cumul.html" NAME="chart">
</FRAMESET>
</HTML>
ENDTXT

# -------------------------------[ Prepare and run the final report script ]---
cat >$SQLSET<<ENDSQLFTS
CONNECT $user/$password@$ORACLE_SID
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${ORACLE_SID}_chart.js
DECLARE
  L_LINE VARCHAR2(4000);
  DB_ID NUMBER; DB_NAME VARCHAR(9); INST_NUM NUMBER; INST_NAME VARCHAR(16);
  EID NUMBER; BID NUMBER; OSPVER VARCHAR2(10);
  BTIME VARCHAR2(20); ETIME VARCHAR2(20); DBUP_ID NUMBER; TDATE DATE;
  DB_BLOCKSIZE NUMBER; I1 NUMBER;

  CURSOR C_MaxSnap IS
    SELECT MAX(snap_id) maxid FROM stats\$snapshot
     WHERE dbid = DB_ID AND instance_number = INST_NUM;

  CURSOR C_MinSnap IS
    SELECT MIN(snap_id) minid FROM stats\$snapshot
     WHERE dbid = DB_ID AND instance_number = INST_NUM
       AND startup_time = (SELECT startup_time FROM stats\$snapshot
                            WHERE dbid = db_id AND instance_number = INST_NUM
			      AND snap_id = EID);

  PROCEDURE print(line IN VARCHAR2) IS
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('*!* Problem in print() *!*');
    END;

  PROCEDURE get_sysevent(eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sev IS
      SELECT arrname||'['||snap_id||'] = '||total_timeouts||';' line,
             NVL(total_timeouts,0) value, snap_id
        FROM stats\$system_event
       WHERE event=eventname
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sev LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sysstat(eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||snap_id||'] = '||value||';' line, value, snap_id
        FROM stats\$sysstat
       WHERE name=eventname
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sysstat2_ps(event1 IN VARCHAR2, event2 IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; LASTVAL NUMBER; ACTVAL NUMBER; VALUE NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||snap_id||'] = '||SUM(value)||';' line,snap_id,SUM(value) val
        FROM stats\$sysstat
       WHERE name IN (event1,event2)
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        ACTVAL := rec.val;
        IF rec.snap_id > bid THEN
          VALUE := ACTVAL - LASTVAL;
          print(arrname||'['||rec.snap_id||'] = '||VALUE||';');
	  IF VALUE > MAXVAL THEN
	    MAXVAL := VALUE;
          END IF;
        END IF;
	LASTVAL := ACTVAL;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sysstat_per(event1 IN VARCHAR2, event2 IN VARCHAR2, arrname IN VARCHAR2, factor IN NUMBER) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||a.snap_id||'] = '||round(factor*a.value/b.value,5)||';' line,
             a.snap_id, round(factor*a.value/b.value,5) value
        FROM stats\$sysstat a, stats\$sysstat b
       WHERE a.name=event1
         AND b.name=event2
         AND a.instance_number=INST_NUM
         AND b.instance_number=INST_NUM
	 AND a.dbid=DB_ID
	 AND b.dbid=DB_ID
	 AND a.snap_id BETWEEN BID AND EID
	 AND a.snap_id=b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_libmiss(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Lib IS
      SELECT arrname||'['||snap_id||'] = '||
             decode(nvl(sum(gets),0),0,0,100-nvl((sum(gethits)/sum(gets)),0)*100)||
	     ';' line, snap_id,
             decode(nvl(sum(gets),0),0,0,100-nvl((sum(gethits)/sum(gets)),0)*100) value
        FROM stats\$librarycache
       WHERE snap_id BETWEEN BID AND EID
         AND dbid = DB_ID
         AND instance_number = INST_NUM
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Lib LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_librpp(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_LibR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(reloads)/sum(pins),3)||';' line,
             snap_id, round(100*sum(reloads)/sum(pins),3) value
        FROM stats\$librarycache
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_LibR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_libghr(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_LibR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(gethits)/sum(gets),3)||';' line,
             snap_id, round(100*sum(gethits)/sum(gets),3) value
        FROM stats\$librarycache
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_LibR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_rowcacheratio(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_RowR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(getmisses)/sum(gets),3)||';' line,
             snap_id, round(100*sum(getmisses)/sum(gets),3) value
        FROM stats\$rowcache_summary
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_RowR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_filereads(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Read IS
      SELECT arrname||'['||b.snap_id||'] = '||round(sum(e.phyblkrd - b.phyblkrd)*DB_BLOCKSIZE/1024/1024,2)||';' line,
             b.snap_id snap_id,
	     round(sum(e.phyblkrd - b.phyblkrd)*DB_BLOCKSIZE/1024/1024,2) value
        FROM stats\$filestatxs b, stats\$filestatxs e
       WHERE e.dbid = DB_ID
         AND b.dbid = DB_ID
         AND e.instance_number = INST_NUM
         AND b.instance_number = INST_NUM
         AND e.snap_id = b.snap_id +1
         AND b.snap_id BETWEEN BID AND EID -1
         AND b.tsname = e.tsname
         AND b.filename = e.filename
       GROUP BY b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Read LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_filewrites(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Read IS
      SELECT arrname||'['||b.snap_id||'] = '||round(sum(e.phyblkwrt - b.phyblkwrt)*DB_BLOCKSIZE/1024/1024,2)||';' line,
             b.snap_id snap_id,
	     round(sum(e.phyblkwrt - b.phyblkwrt)*DB_BLOCKSIZE/1024/1024,2) value
        FROM stats\$filestatxs b, stats\$filestatxs e
       WHERE e.dbid = DB_ID
         AND b.dbid = DB_ID
         AND e.instance_number = INST_NUM
         AND b.instance_number = INST_NUM
         AND e.snap_id = b.snap_id +1
         AND b.snap_id BETWEEN bid AND eid -1
         AND b.tsname = e.tsname
         AND b.filename = e.filename
       GROUP BY b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Read LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

BEGIN
  OSPVER := '$version';
  dbms_output.enable(1000000);

  SELECT d.dbid,d.name,i.instance_number,i.instance_name
    INTO DB_ID,DB_NAME,INST_NUM,INST_NAME
    FROM v\$database d,v\$instance i;

  FOR R_SnapID IN C_MaxSnap LOOP
    I1 := R_SnapID.maxid;
  END LOOP;

  IF NVL($END_ID,0) = 0 THEN
    EID := I1;
  ELSE
    IF $END_ID > I1 THEN
      EID := I1;
    ELSE
      EID := $END_ID;
    END IF;
  END IF;
  FOR R_SnapID IN C_MinSnap LOOP
    DBUP_ID := R_SnapID.minid;
  END LOOP;
  IF NVL($START_ID,0) = 0
  THEN
    IF NVL($MAX_CHART_INTERVAL,0) != 0 THEN
      SELECT (snap_time - $MAX_CHART_INTERVAL) INTO TDATE FROM stats\$snapshot WHERE snap_id=EID;
      SELECT MAX(snap_id) INTO BID FROM stats\$snapshot WHERE snap_time<TDATE;
      IF BID < DBUP_ID THEN
        BID := DBUP_ID;
      END IF;
    ELSE
      BID := DBUP_ID;
    END IF;
  ELSE
    IF $START_ID < DBUP_ID THEN
      BID := DBUP_ID;
    ELSE
      BID := $START_ID;
    END IF;
  END IF;

  SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO BTIME
    FROM stats\$snapshot
   WHERE snap_id=BID;
  SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO ETIME
    FROM stats\$snapshot
   WHERE snap_id=EID;

  SELECT value INTO DB_BLOCKSIZE
    FROM stats\$parameter
   WHERE name='db_block_size'
     AND snap_id = EID
     AND instance_number=INST_NUM
     AND dbid=DBID;

  -- General variables
  print('var bid   = '||bid||';');
  print('var eid   = '||eid||';');
  print('var btime = "'||BTIME||'";');
  print('var etime = "'||ETIME||'";');
  print('var dbup_id = '||DBUP_ID||';');
  print('var amaxval = new Array();');
  print('var amaxdelta = new Array();');
  print('var amaxavedelta = new Array();');

  -- Chart statistics
  get_sysevent('free buffer waits','freebuff');
  get_sysevent('buffer busy waits','busybuff');
  get_sysevent('db file sequential read','fileseq');
  get_sysevent('db file scattered read','filescat');
  get_sysevent('enqueue','enq');
  get_sysevent('LGWR wait for redo copy','lgwr');
  get_sysevent('log file switch completion','lgsw');
  get_sysevent('log file switch (checkpoint incomplete)','ckpt');
  get_sysstat('redo log space requests','redoreq');
  get_sysstat_per('enqueue timeouts','enqueue requests','enqper',1);
  get_sysstat_per('free buffer inspected','free buffer requested','fbp',1);
  get_sysstat_per('table fetch continued row','table fetch by rowid','cfr',100);
  get_libmiss('libmiss');
  get_sysstat('logons current','logon');
  get_sysstat('opened cursors current','opencur');
  get_librpp('rpp');
  get_libghr('ghr');
  get_rowcacheratio('rcr');
  get_filereads('phyrd');
  get_filewrites('phywrt');
  get_sysstat2_ps('user commits','transaction rollbacks','tx');

END;
/

ENDSQLFTS

#cat $SQLSET >osp_charts.out
cat $SQLSET | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
