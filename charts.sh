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
# -------------------------------------------[ Read the Configuration File ]---
. ./config $*
# ------------------------------------------[ process command line options ]---
while [ "$1" != "" ] ; do
  case "$1" in
    -s) shift; ORACLE_CONNECT=$1;;
    -u) shift; user=$1;;
    -p) shift; password=$1;;
    -e) shift; END_ID=$1;;
    -b) shift; START_ID=$1;;
  esac
  shift
done
if [ -z "$ORACLE_CONNECT" ]; then
  ORACLE_CONNECT=$ORACLE_SID
fi
if [ -n $START_ID ]; then
  if [ -z $END_ID ]; then
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
<FRAMESET COLS="1,*">
 <FRAME NAME="menu">
 <FRAME SRC="inc/cumul.html" NAME="main">
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
  DBID NUMBER; DB_NAME VARCHAR(9); INST_NUM NUMBER; INST_NAME VARCHAR(16);
  EID NUMBER; BID NUMBER; OSPVER VARCHAR2(10);
  BTIME VARCHAR2(20); ETIME VARCHAR2(20);

  CURSOR C_MaxSnap(db_id IN NUMBER, instnum IN NUMBER) IS
    SELECT MAX(snap_id) maxid FROM stats\$snapshot
     WHERE dbid = db_id AND instance_number = instnum;

  CURSOR C_MinSnap(db_id IN NUMBER, instnum IN NUMBER, maxsnap IN NUMBER) IS
    SELECT MIN(snap_id) minid FROM stats\$snapshot
     WHERE dbid = db_id AND instance_number = instnum
       AND startup_time = (SELECT startup_time FROM stats\$snapshot
                            WHERE dbid = db_id AND instance_number = instnum
			      AND snap_id = maxsnap);

  PROCEDURE print(line IN VARCHAR2) IS
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('*!* Problem in print() *!*');
    END;

  PROCEDURE get_sysevent(db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    CURSOR C_Sev(db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, eventname IN VARCHAR2, arrname IN VARCHAR2) IS
      SELECT arrname||'['||snap_id||'] = '||total_timeouts||';' line
        FROM stats\$system_event
       WHERE event=eventname
         AND instance_number=instnum
	 AND dbid=db_id
	 AND snap_id BETWEEN bid AND eid;
    BEGIN
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sev(db_id,instnum,bid,eid,eventname,arrname) LOOP
        print(rec.line);
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

BEGIN
  OSPVER := '$version';
  dbms_output.enable(1000000);

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

  SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO BTIME
    FROM stats\$snapshot
   WHERE snap_id=BID;
  SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO ETIME
    FROM stats\$snapshot
   WHERE snap_id=EID;

  -- General variables
  print('var bid   = '||bid||';');
  print('var eid   = '||eid||';');
  print('var btime = "'||BTIME||'";');
  print('var etime = "'||ETIME||'";');

  -- Chart statistics
  get_sysevent(DBID,INST_NUM,BID,EID,'free buffer waits','freebuff');  
  get_sysevent(DBID,INST_NUM,BID,EID,'buffer busy waits','busybuff');  
  get_sysevent(DBID,INST_NUM,BID,EID,'db file sequential read','fileseq');  
  get_sysevent(DBID,INST_NUM,BID,EID,'db file scattered read','filescat');  
  get_sysevent(DBID,INST_NUM,BID,EID,'enqueue','enq');  
  get_sysevent(DBID,INST_NUM,BID,EID,'LGWR wait for redo copy','lgwr');  
  get_sysevent(DBID,INST_NUM,BID,EID,'log file switch completion','lgsw');  

END;
/

ENDSQLFTS

#cat $SQLSET >osp_charts.out
cat $SQLSET | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
