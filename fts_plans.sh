#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html  (c) 2003-2005 by IzzySoft (devel@izzysoft.de)     
# -----------------------------------------------------------------------------
# FTS Module
# -----------------------------------------------------------------------------
# Retrieves execution plans for all statements that caused Full Table Scans
# (FTS). These are the statements that most likely require some optimization
# concerning missing indices and/or SQL syntax.
#                                                              Itzchak Rehberg
# =============================================================================
#
. ./version
# =======================================================[ Header / Syntax ]===
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OSPRep v$version           (c) 2003-2005 by Itzchak Rehberg (devel@izzysoft.de)"
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
  echo "     -o <Output Filename>"
  echo "     -p <Password>"
  echo "     -r <ReportDirectory>"
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
    -r) shift; REPORTDIR=$1;;
    -o) shift; FILENAME=$1;;
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
if [ -n "$REPORTDIR" ]; then
  REPDIR=$REPORTDIR
fi
if [ -z "$FILENAME" ]; then
  FILENAME="${ORACLE_SID}_fts.html"
fi

SQLSET=$TMPDIR/osprep_fts_$ORACLE_SID.$$

# ---------------------------------------------------[ Setup some Settings ]---
if [ "$EXC_PERF_FOR" = "" ];
then EXCLUDE_OWNERS="'NULL'"
else
  for i in $EXC_PERF_FOR; do
    if [ "$EXCLUDE_OWNERS" = "" ];
    then EXCLUDE_OWNERS="'$i'"
    else EXCLUDE_OWNERS="$EXCLUDE_OWNERS,'$i'"
    fi
  done
fi

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
SPOOL $REPDIR/${FILENAME}
DECLARE
  L_LINE VARCHAR2(4000);
  R_TITLE VARCHAR2(200);
  TABLE_OPEN VARCHAR2(100); -- Table Attributes
  TABLE_CLOSE VARCHAR2(100);
  DB_ID NUMBER; DB_NAME VARCHAR(9); INST_NUM NUMBER; INST_NAME VARCHAR(16);
  EID NUMBER; BID NUMBER; OSPVER VARCHAR2(10); I1 NUMBER;

  CURSOR C_MaxSnap IS
    SELECT MAX(snap_id) maxid FROM stats\$snapshot
     WHERE dbid = DB_ID AND instance_number = INST_NUM;

  CURSOR C_MinSnap IS
    SELECT MIN(snap_id) minid FROM stats\$snapshot
     WHERE dbid = DB_ID AND instance_number = INST_NUM
       AND startup_time = (SELECT startup_time FROM stats\$snapshot
                            WHERE dbid = DB_ID AND instance_number = INST_NUM
			      AND snap_id = EID);

  CURSOR C_GetSQL (hv IN NUMBER) IS
    SELECT replace(replace(sql_text,'<','&lt;'),'>','&gt;') AS sql_text
      FROM stats\$sqltext WHERE hash_value=hv
     ORDER BY piece;

  CURSOR C_GetHashes IS
    SELECT DISTINCT a.plan_hash_value AS phashval,
           b.hash_value AS hashval,
	   b.cost,
           TO_CHAR(c.snap_time,'dd.mm.yyyy') AS snapdate
      FROM stats\$sql_plan a, stats\$sql_plan_usage b, stats\$snapshot c
     WHERE a.operation='TABLE ACCESS'
       AND a.options='FULL'
       AND a.snap_id BETWEEN BID AND EID
       AND b.snap_id BETWEEN BID AND EID
       AND a.plan_hash_value=b.plan_hash_value
       AND b.snap_id=c.snap_id
       AND a.object_owner NOT IN ($EXCLUDE_OWNERS)
     ORDER BY b.cost DESC;

  PROCEDURE print(line IN VARCHAR2) IS
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLERRM LIKE '%ORU-10028%' THEN
	  print(SUBSTR(line,1,255));
	  print(SUBSTR(line,256));
	ELSE
          dbms_output.put_line('*!* Problem in print() *!*');
	END IF;
    END;

  PROCEDURE get_plan (hashval IN VARCHAR2) IS
    HASHID NUMBER; CI NUMBER; SI NUMBER; OSIZE VARCHAR2(50); IND VARCHAR2(255);
    CW NUMBER; S1 VARCHAR2(50); TDI VARCHAR2(20);
    CURSOR C_PGet (hash_val IN VARCHAR2) IS
      SELECT operation,options,object_owner,object_name,optimizer,
             NVL(TO_CHAR(cost,'999,990'),'&nbsp;') cost,
             cost ncost,
             bytes,cpu_cost,io_cost,depth
        FROM stats\$sql_plan,
	     ( SELECT MAX(snap_id) maxid FROM stats\$sql_plan
	        WHERE snap_id BETWEEN BID AND EID
		  AND plan_hash_value = hash_val ) id
       WHERE plan_hash_value = hash_val
	 ORDER BY id;
    BEGIN
      SELECT MAX(snap_id) INTO SI
        FROM ( SELECT plan_hash_value,snap_id
                 FROM stats\$sql_plan_usage
                WHERE hash_value = hashval
                  AND snap_id BETWEEN BID AND EID );
      SELECT MAX(plan_hash_value) INTO HASHID
        FROM ( SELECT plan_hash_value,snap_id
                 FROM stats\$sql_plan_usage
                WHERE hash_value = hashval
                  AND snap_id=SI );
      SELECT COUNT(snap_id) INTO CI
        FROM stats\$sql_plan
       WHERE plan_hash_value = HASHID
	 AND object_owner NOT IN ($EXCLUDE_OWNERS);
      IF CI > 0
      THEN
        CW := 20;
        print('<TR><TD>&nbsp;</TD><TD>');
        print(TABLE_OPEN||'<TR><TH CLASS="th_sub">Operation</TH><TH CLASS="th_sub">'||
              'Object</TH><TH CLASS="th_sub">');
        print('Optimizer</TH><TH CLASS="th_sub">Cost</TH><TH CLASS="th_sub">'||
              'CPUCost</TH><TH CLASS="th_sub">IOCost</TH><TH CLASS="th_sub">'||
              'Size</TH></TR>');
        FOR rplan IN C_PGet(HASHID) LOOP
          IF NVL(rplan.bytes,0) < 1024 THEN
            OSIZE := TO_CHAR(rplan.bytes,'9,990');
            IF NVL(OSIZE,'X') = 'X' THEN
              OSIZE := '&nbsp;';
            ELSE
              OSIZE := OSIZE||' b';
            END IF;
          ELSE
            OSIZE := TO_CHAR(rplan.bytes/1024,'999,999,990')||' k';
          END IF;
	  IND := '';
	  FOR CI IN 1..rplan.depth LOOP
	    IND := IND||'. ';
	  END LOOP;
	  SI := 11*(LENGTH(rplan.operation) + LENGTH(rplan.options) + 2*rplan.depth)/9;
	  CI := 3*(LENGTH(OSIZE)+1)/10;
	  IF SI > CW THEN CW := SI; END IF;
	  IF rplan.operation||' '||rplan.options = 'TABLE ACCESS FULL' THEN
	    IF NVL(rplan.ncost,0) > $AR_EP_FTS THEN
	      S1 := ' CLASS="alert"';
	    ELSE
	      S1 := ' CLASS="warn"';
	    END IF;
            TDI := '';
	  ELSE
	    S1 := '';
            TDI := ' CLASS="inner"';
	  END IF;
          print('<TR'||S1||'><TD'||TDI||'><DIV STYLE="width:'||5*CW/9||'em"><CODE>'||IND||rplan.operation||' '||rplan.options||
                '</CODE></DIV></TD><TD'||TDI||'>'||rplan.object_owner||'.'||rplan.object_name||
                '</TD><TD'||TDI||'>'||NVL(rplan.optimizer,'&nbsp;'));
          print('</TD><TD ALIGN="right"'||TDI||'>'||rplan.cost||'</TD><TD ALIGN="right"'||TDI||'>'||
                NVL(TO_CHAR(rplan.cpu_cost,'999,990'),'&nbsp;')||
                '</TD><TD ALIGN="right"'||TDI||'>'||NVL(TO_CHAR(rplan.io_cost,'999,990'),'&nbsp;')||
                '</TD><TD ALIGN="right"'||TDI||'><DIV STYLE="width:'||CI||'em">'||OSIZE||'</DIV></TD></TR>');
        END LOOP;
        print('</TABLE></TD></TR>');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

BEGIN
  OSPVER := '$version';
  dbms_output.enable(1000000);
  R_TITLE := 'StatsPack Report for $ORACLE_SID: FTS Analysis';
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

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
  IF NVL($START_ID,0) = 0 THEN
    FOR R_SnapID IN C_MinSnap LOOP
      BID := R_SnapID.minid;
    END LOOP;
  ELSE
    BID := $START_ID;
  END IF;

  -- HTML Head
  L_LINE := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'||CHR(10)||
            '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  print(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="$CSS">'||CHR(10)||
            ' <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">'||CHR(10)||
	    '   function popup(page) {'||CHR(10)||
	    '     url = "help/" + page + ".html";';
  print(L_LINE);
  L_LINE := '     pos = (screen.width/2)-400;'||CHR(10)||
            '     helpwin = eval("window.open(url,'||CHR(39)||'help'||CHR(39)||
	    ','||CHR(39)||'toolbar=no,location=no,titlebar=no,directories=no,'||
	    'status=yes,copyhistory=no,scrollbars=yes,width=600,height=400,top=0,left="+pos+"'||
	    CHR(39)||')");';
  print(L_LINE);
  L_LINE := '   }'||CHR(10)||' </SCRIPT>'||CHR(10)||
            '</HEAD><BODY>'||CHR(10)||'<H2>'||R_TITLE||'</H2>'||CHR(10);
  print(L_LINE);

  -- Make the Plan tables
  print(TABLE_OPEN||' <TR><TH>LastRec</TH><TH>Statement</TH></TR>');
  FOR recHash in C_GetHashes LOOP
    print('<TR><TD CLASS="td_name">'||recHash.snapdate||'</TD><TD CLASS="td_name">');
    FOR recSQL IN C_GetSQL(recHash.hashval) LOOP
      print(recSQL.sql_text);
    END LOOP;
    print('</TD></TR>');
    get_plan(recHash.hashval);
  END LOOP;
  print(TABLE_CLOSE);

  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN||
            '<TR><TD><IMG SRC="w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small">';
  print(L_LINE);
  L_LINE := 'Created by OSPRep v'||OSPVER||' (FTS module) &copy; 2003-2005 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></SPAN>';
  print(L_LINE);
  L_LINE := '<IMG SRC="islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-left:3px"></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

ENDSQLFTS

#cat $SQLSET >osp_fts.out
cat $SQLSET | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
