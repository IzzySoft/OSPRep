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
# =============================================================================
#
version='0.1.3'
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
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [StartID EndID]"
  echo ============================================================================
  echo
  exit 1
fi

# =================================================[ Configuration Section ]===
# -------------------------------------------[ Read the Configuration File ]---
. ./config $*
SQLSET=$TMPDIR/osprep_sqlset_$1.$$
TMPOUT=$TMPDIR/osprep_tmpout_$1.$$
GWDUMMY=$TMPDIR/osprep_gwdummy_$1.$$

# If Start/End ID are specified on CmdLine, override internal settings:
if [ -n "$2" ]; then
  START_ID=$2
fi
if [ -n "$3" ]; then
  END_ID=$3
fi

# --------------------------------[ Get the Oracle version of the DataBase ]---
cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$1
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

cat $SQLSET getver.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
DBVER=`cat $TMPOUT`
SPFILE=sp$DBVER.pls
cat $SQLSET checkwt.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
WTEXISTS=`cat $TMPOUT`
if [ "$WTEXISTS" = "1" ];
then
  GETWAITS="./getwaits.prc"
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
CONNECT $user/$password@$1
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${ORACLE_SID}.html
ENDSQL

. ./ospopen
# cat $SQLSET $SPFILE ospout.pls >osp.out
cat $SQLSET $SPFILE ospout.pls | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
rm $TMPOUT
