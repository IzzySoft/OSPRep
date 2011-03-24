#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html  (c) 2003-2005 by IzzySoft (devel@izzysoft.de)     
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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN">
<HTML><HEAD>
 <TITLE>DBStats for ${ORACLE_SID}</TITLE>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript" SRC="${ORACLE_SID}_chart.js"></SCRIPT>
 <SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
   var dstat = enq;
   var dname = "Enqueues";
   var sid   = "${ORACLE_SID}";
   var vers  = "${version}";
 //--></SCRIPT>
</HEAD>
<FRAMESET COLS="70,*">
 <FRAME SRC="inc/nav.html" NAME="menu" FRAMEBORDER="0">
 <FRAME SRC="inc/cumul.html" NAME="chart" FRAMEBORDER="0">
</FRAMESET>
</HTML>
ENDTXT

# -------------------------------[ Prepare and run the final report script ]---
cat >$SQLSET<<ENDSQLFTS
CONNECT $user/$password@$ORACLE_CONNECT
ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${ORACLE_SID}_chart.js
exec osprep.chart_data($START_ID,$END_ID,$MAX_CHART_INTERVAL);

ENDSQLFTS

#cat $SQLSET >osp_charts.out
cat $SQLSET | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
