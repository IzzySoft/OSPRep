#!/bin/bash
# $Id$
#
# =============================================================================
# Oracle StatsPack Report 2 Html  (c) 2003-2004 by IzzySoft (devel@izzysoft.de)     
# -----------------------------------------------------------------------------
# This report script creates a HTML document containing the StatsPack Report.
# It is a simple rewrite of the standard sprepins.sql script
# I'ld never claim this report tool to be perfect, complete or "state of the
# art". But it's simple to use and very helpful to those not having a license
# to the expensive AddOns available at Oracle. Any hints on errors or bugs as
# well as recommendations for additions are always welcome.
#                                                              Itzchak Rehberg
# =============================================================================
#
# =======================================================[ Header / Syntax ]===
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
BINDIR=${0%/*}
PLUGINDIR=$BINDIR/plugins

# -------------------------------------------[ Read the Configuration File ]---
. $BINDIR/config $*
#SQLFILE=$TMPDIR/osprep_execfile_$ORACLE_SID.$$

if [ $MK_BGWAITS -eq 1 ]; then
  BGWAITHEAD=$PLUGINDIR/bgwait_head.pls
  BGWAITBODY=$PLUGINDIR/bgwait_body.pls
fi
if [ $MK_ALLWAITS -eq 1 ]; then
  ALLWAITHEAD=$PLUGINDIR/allwait_head.pls
  ALLWAITBODY=$PLUGINDIR/allwait_body.pls
fi
if [ $MK_INSTACT -eq 1 ]; then
  INSTACTHEAD=$PLUGINDIR/instact_head.pls
  INSTACTBODY=$PLUGINDIR/instact_body.pls
fi
if [ $MK_USSTAT -eq 1 ]; then
  USSTATHEAD=$PLUGINDIR/undo_head.pls
  USSTATBODY=$PLUGINDIR/undo_body.pls
fi

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

. $BINDIR/version
SQLSET=$TMPDIR/osprep_sqlset_$ORACLE_SID.$$
TMPOUT=$TMPDIR/osprep_tmpout_$ORACLE_SID.$$
GWDUMMY=$TMPDIR/osprep_gwdummy_$ORACLE_SID.$$
DFDUMMY=$TMPDIR/osprep_dfdummy_$ORACLE_SID.$$

# --------------------------------[ Get the Oracle version of the DataBase ]---
cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$ORACLE_CONNECT
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
Set PAGESIZE 0
SPOOL $TMPOUT
ENDSQL

cat $SQLSET $PLUGINDIR/getver.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
DBVER=`cat $TMPOUT`
SPFILE=$PLUGINDIR/sp$DBVER.pls

# ----------------------------------[ Check for the AddOns and set them up ]---
cat $SQLSET $PLUGINDIR/checkwt.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
WTEXISTS=`cat $TMPOUT`
if [ "$WTEXISTS" = "1" ];
then
  GETWAITS="$PLUGINDIR/getwaits.prc"
else
  cat >$GWDUMMY<<ENDSQL
  cat>>$SQLSET<<ENDDUMMY
  PROCEDURE get_waitobj(db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
  BEGIN
    NULL;
  END;
ENDDUMMY
ENDSQL
  chmod u+x $GWDUMMY
  GETWAITS=$GWDUMMY
fi

cat $SQLSET $PLUGINDIR/checkdf.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
DFEXISTS=`cat $TMPOUT`
if [ "$DFEXISTS" = "1" ];
then
  GETDF="$PLUGINDIR/getfilestat.prc"
else
  cat >$DFDUMMY<<ENDSQL
  cat>>$SQLSET<<ENDDUMMY
  PROCEDURE get_filestats(db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
  BEGIN
    NULL;
  END;
ENDDUMMY
ENDSQL
  chmod u+x $DFDUMMY
  GETDF=$DFDUMMY
fi

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
cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$ORACLE_CONNECT
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
variable MK_ALLWAITS NUMBER;
variable MK_BGWAITS NUMBER;
variable MK_INSTACT NUMBER;
variable MK_USSTAT NUMBER;
BEGIN
  :MK_ALLWAITS := $MK_ALLWAITS;
  :MK_BGWAITS  := $MK_BGWAITS;
  :MK_INSTACT  := $MK_INSTACT;
  :MK_USSTAT   := $MK_USSTAT;
END;
/
SPOOL $REPDIR/${ORACLE_SID}.html
ENDSQL

. $BINDIR/ospopen
#cat $SQLSET $SPFILE $BINDIR/ospout.pls $ALLWAITBODY $BGWAITBODY $BINDIR/ospout02.pls $INSTACTBODY $BINDIR/ospout03.pls $USSTATBODY $BINDIR/ospout04.pls >osp.out
cat $SQLSET $SPFILE $BINDIR/ospout.pls $ALLWAITBODY $BGWAITBODY $BINDIR/ospout02.pls $INSTACTBODY $BINDIR/ospout03.pls $USSTATBODY $BINDIR/ospout04.pls | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
rm $TMPOUT
