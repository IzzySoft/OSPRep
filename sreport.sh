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
CONFIG=$BINDIR/config
ARGS=$*
PLUGINDIR=$BINDIR/plugins
RULER=$PLUGINDIR/ruler.pls

# ------------------------------------------[ process command line options ]---
while [ "$1" != "" ] ; do
  case "$1" in
    -s) shift; ORACLE_CONNECT=$1;;
    -u) shift; username=$1;;
    -p) shift; passwd=$1;;
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
if [ -n "$username" ]; then
  user=$username
fi
if [ -n "$passwd" ]; then
  password=$passwd
fi

# ---------------------------------------------------[ Prepare the PlugIns ]---
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
if [ $MK_LACT -eq 1 ]; then
  LACTHEAD=$PLUGINDIR/lact_head.pls
  LACTBODY=$PLUGINDIR/lact_body.pls
  if [ $MK_LMS -eq 1 ]; then
    LMSHEAD=$PLUGINDIR/lms_head.pls
    LMSBODY=$PLUGINDIR/lms_body.pls
  fi
fi
if [ "${MK_RSSTAT}${MK_RSSTOR}" != "00" ]; then
  RBSHEAD=$PLUGINDIR/rbs_head.pls
  RBSBODY=$PLUGINDIR/rbs_body.pls
fi
if [ "${MK_LC}${MK_DC}" != "00" ]; then
  CACHEHEAD=$PLUGINDIR/cache_head.pls
  CACHEBODY=$PLUGINDIR/cache_body.pls
fi
if [ $MK_SGASUM -eq 1 ]; then
  SGAHEAD=$PLUGINDIR/sga_head.pls
  SGABODY=$PLUGINDIR/sga_body.pls
fi
if [ $MK_IORA -eq 1 ]; then
  IORAHEAD=$PLUGINDIR/iora_head.pls
  IORABODY=$PLUGINDIR/iora_body.pls
fi

. $BINDIR/version
SQLSET=$TMPDIR/osprep_sqlset_$ORACLE_SID.$$
TMPOUT=$TMPDIR/osprep_tmpout_$ORACLE_SID.$$
GWDUMMY=$TMPDIR/osprep_gwdummy_$ORACLE_SID.$$
DFDUMMY=$TMPDIR/osprep_dfdummy_$ORACLE_SID.$$

# ==========================================[ Start the Run of the Scripts ]===
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
variable MK_LACT NUMBER;
variable MK_LMS NUMBER;
variable MK_IORA NUMBER;
variable MK_SGASUM NUMBER;
variable MK_SGABREAK NUMBER;
variable MK_DC NUMBER;
variable MK_LC NUMBER;
variable MK_RSSTAT NUMBER;
variable MK_RSSTOR NUMBER;
variable WR_IE_BUFFNW NUMBER;
variable AR_IE_BUFFNW NUMBER;
variable WR_IE_REDONW NUMBER;
variable AR_IE_REDONW NUMBER;
variable WR_IE_BUFFHIT NUMBER;
variable AR_IE_BUFFHIT NUMBER;
variable WR_IE_IMSORT NUMBER;
variable AR_IE_IMSORT NUMBER;
variable WR_IE_LIBHIT NUMBER;
variable AR_IE_LIBHIT NUMBER;
variable WR_IE_SOFTPRS NUMBER;
variable AR_IE_SOFTPRS NUMBER;
variable WR_IE_PRSC2E NUMBER;
variable AR_IE_PRSC2E NUMBER;
variable WR_IE_LAHIT NUMBER;
variable AR_IE_LAHIT NUMBER;
variable AR_EP_FTS NUMBER;
variable WR_DF_CHNG NUMBER;
variable AR_DF_CHNG NUMBER;
variable WR_TS_BLKRD NUMBER;
variable AR_TS_BLKRD NUMBER;
variable WR_TS_RD NUMBER;
variable AR_TS_RD NUMBER;
variable WR_LC_MISS NUMBER;
variable AR_LC_MISS NUMBER;
variable WR_LC_RLPRQ NUMBER;
variable AR_LC_RLPRQ NUMBER;
variable WR_LC_INVPRQ NUMBER;
variable AR_LC_INVPRQ NUMBER;
BEGIN
  :MK_ALLWAITS := $MK_ALLWAITS;
  :MK_BGWAITS  := $MK_BGWAITS;
  :MK_INSTACT  := $MK_INSTACT;
  :MK_USSTAT   := $MK_USSTAT;
  :MK_LACT     := $MK_LACT;
  :MK_LMS      := $MK_LMS;
  :MK_IORA     := $MK_IORA;
  :MK_SGASUM   := $MK_SGASUM;
  :MK_SGABREAK := $MK_SGABREAK;
  :MK_DC       := $MK_DC;
  :MK_LC       := $MK_LC;
  :MK_RSSTAT   := $MK_RSSTAT;
  :MK_RSSTOR   := $MK_RSSTOR;
  :WR_IE_BUFFNW  := $WR_IE_BUFFNW;
  :AR_IE_BUFFNW  := $AR_IE_BUFFNW;
  :WR_IE_REDONW  := $WR_IE_REDONW;
  :AR_IE_REDONW  := $AR_IE_REDONW;
  :WR_IE_BUFFHIT := $WR_IE_BUFFHIT;
  :AR_IE_BUFFHIT := $AR_IE_BUFFHIT;
  :WR_IE_IMSORT  := $WR_IE_IMSORT;
  :AR_IE_IMSORT  := $AR_IE_IMSORT;
  :WR_IE_LIBHIT  := $WR_IE_LIBHIT;
  :AR_IE_LIBHIT  := $AR_IE_LIBHIT;
  :WR_IE_SOFTPRS := $WR_IE_SOFTPRS;
  :AR_IE_SOFTPRS := $AR_IE_SOFTPRS;
  :WR_IE_PRSC2E  := $WR_IE_PRSC2E;
  :AR_IE_PRSC2E  := $AR_IE_PRSC2E;
  :WR_IE_LAHIT   := $WR_IE_LAHIT;
  :AR_IE_LAHIT   := $AR_IE_LAHIT;
  :AR_EP_FTS     := $AR_EP_FTS;
  :WR_DF_CHNG    := $WR_DF_CHNG;
  :AR_DF_CHNG    := $AR_DF_CHNG;
  :WR_TS_BLKRD   := $WR_TS_BLKRD;
  :AR_TS_BLKRD   := $AR_TS_BLKRD;
  :WR_TS_RD      := $WR_TS_RD;
  :AR_TS_RD      := $AR_TS_RD;
  :WR_LC_MISS    := $WR_LC_MISS;
  :AR_LC_MISS    := $AR_LC_MISS;
  :WR_LC_RLPRQ   := $WR_LC_RLPRQ;
  :AR_LC_RLPRQ   := $AR_LC_RLPRQ;
  :WR_LC_INVPRQ  := $WR_LC_INVPRQ;
  :AR_LC_INVPRQ  := $AR_LC_INVPRQ;
END;
/
SPOOL $REPDIR/${ORACLE_SID}.html
ENDSQL

. $BINDIR/ospopen
#cat $SQLSET $SPFILE $BINDIR/ospout.pls $ALLWAITBODY $BGWAITBODY $BINDIR/ospout02.pls $INSTACTBODY $BINDIR/ospout03.pls $USSTATBODY $RULER $RBSBODY $LACTBODY $LMSBODY $CACHEBODY $SGABODY $PLUGINDIR/rlims.pls $IORABODY $BINDIR/footer.pls >osp.out
cat $SQLSET $SPFILE $BINDIR/ospout.pls $ALLWAITBODY $BGWAITBODY $BINDIR/ospout02.pls $INSTACTBODY $BINDIR/ospout03.pls $USSTATBODY $RULER $RBSBODY $LACTBODY $LMSBODY $CACHEBODY $SGABODY $PLUGINDIR/rlims.pls $IORABODY $BINDIR/footer.pls | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm -f $SQLSET $TMPOUT $GWDUMMY $DFDUMMY
