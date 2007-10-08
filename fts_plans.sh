#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html  (c) 2003-2007 by IzzySoft (devel@izzysoft.de)     
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
  echo "OSPRep v$version           (c) 2003-2007 by Itzchak Rehberg (devel@izzysoft.de)"
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
then EXCLUDE_OWNERS="''NULL''"
else
  for i in $EXC_PERF_FOR; do
    if [ "$EXCLUDE_OWNERS" = "" ];
    then EXCLUDE_OWNERS="''$i''"
    else EXCLUDE_OWNERS="$EXCLUDE_OWNERS,''$i''"
    fi
  done
fi

# -------------------------------[ Prepare and run the final report script ]---
$ORACLE_HOME/bin/sqlplus -s /NOLOG <<ENDSQLFTS
CONNECT $user/$password@$ORACLE_CONNECT
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL ON
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${FILENAME}
-- HTML HEAD
PROMPT <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
PROMPT <HTML><HEAD>
PROMPT  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
PROMPT  <TITLE>StatsPack Report for $ORACLE_SID: FTS Analysis</TITLE>
PROMPT  <LINK REL="stylesheet" TYPE="text/css" HREF="$CSS">
PROMPT  <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
PROMPT   function popup(page) {
PROMPT    url = "help/" + page + ".html";
PROMPT    pos = (screen.width/2)-400;
PROMPT    helpwin = eval("window.open(url,'help','toolbar=no,location=no,titlebar=no,directories=no,status=yes,copyhistory=no,scrollbars=yes,width=600,height=400,top=0,left="+pos+"')");
PROMPT    version = "$version";
PROMPT   }
PROMPT  </SCRIPT>
PROMPT </HEAD><BODY>
PROMPT <H2>StatsPack Report for $ORACLE_SID: FTS Analysis&nbsp;<A HREF="JavaScript:popup('fts')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></H2>
exec osprep.set_exclude_owners('$EXCLUDE_OWNERS');
exec osprep.fts_plan($START_ID,$END_ID,$MAX_REP_INTERVAL);
SPOOL OFF

ENDSQLFTS

# ----------------------------------[ Add HTML footer to the report output ]---
cat >>$REPDIR/${FILENAME}<<ENDPAGE
<HR>
<TABLE ALIGN="center" BORDER="1">
  <TR><TD><IMG SRC="w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small">
    Created by OSPRep v$version (FTS module) &copy; 2003-2007 by
    Itzchak Rehberg &amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></SPAN>
    <IMG SRC="islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"></TD></TR>
</TABLE>
<BR CLEAR="all">
</BODY></HTML>

ENDPAGE
