#!/bin/bash
#=============================================================================
# StatsPack installation with IzzySoft extensions         (c) 2007 by IzzySoft
#-----------------------------------------------------------------------------
# This script shall help you to easily setup statspack including the
# extensions shipped with OSPRep. Simply adjust the configuration in the
# [ User Configuration ] section below (make sure the specified tablespaces
# exist and have sufficient space available), and run the script. Everything
# should be installed then without any interaction.
#=============================================================================
# $Id$

#----------------------------------------------------[ User Configuration ]---
# Directory to the IzzySoft extensions
IZ_INSTALL_DIR=/home/oracle/osprep/install/database
# Scripts to install
I_FILE_STATS=1
I_SES_STAT=1
I_WAIT_STAT=1
I_ADDONS=1

# Perfstat Password
PERFPWD=perfstat

# Default Tablespaces for Perfstat
DEFAULT_TS=tools
TEMP_TS=TEMP

# Name of the spool file (Installation log - the extension .log will be added
# automatically by the script)
SPOOL="OSPInst"

#------------------------------[ Internal Setup - no need to config here! ]---
# Script Definitions

IZ_FILEOBJ=${IZ_INSTALL_DIR}/fileobj.sql
IZ_FILESTAT=${IZ_INSTALL_DIR}/getfilestat.sql
IZ_SESSTAT=${IZ_INSTALL_DIR}/get_sesstat.sql
IZ_WAITOBJ=${IZ_INSTALL_DIR}/waitobj.sql
IZ_WAITSTAT=${IZ_INSTALL_DIR}/getwaits.sql
IZ_ADDONS=${IZ_INSTALL_DIR}/pkg_osprep.sql
IZ_JOB="statspack.snap;"

TMPFILE=/tmp/iz_stats.$$

# Setup the desired scripts
[ $I_FILE_STATS -eq 1 ] && {
  echo "@${IZ_FILEOBJ}" >>$TMPFILE
  echo "@${IZ_FILESTAT}" >>$TMPFILE
  IZ_JOB="${IZ_JOB} get_fileinfo;"
}
[ $I_SES_STAT -eq 1 ] && {
  echo "@${IZ_SESSTAT}" >>$TMPFILE
  IZ_JOB="${IZ_JOB} get_sesstat;"
}
[ $I_WAIT_STAT -eq 1 ] && {
  echo "@${IZ_WAITOBJ}" >>$TMPFILE
  echo "@${IZ_WAITSTAT}" >>$TMPFILE
  IZ_JOB="${IZ_JOB} get_waitevents;"
}
[ $I_ADDONS -eq 1 ] && echo "@${IZ_ADDONS}" >>$TMPFILE

#-----------------------------------------------------------[ Do the job! ]---
# Install Oracle StatsPack packages
$ORACLE_HOME/bin/sqlplus /nolog <<ENDSQL
  SPOOL ${SPOOL}1.log
  SET TERMOUT ON SERVEROUTPUT ON FEEDBACK ON LINESIZE 300
  conn / as sysdba
  define default_tablespace = '$DEFAULT_TS'
  define temporary_tablespace = '$TEMP_TS'
  define perfstat_password = '$PERFPWD'
  @?/rdbms/admin/spcreate
  SPOOL ${SPOOL}2.log
  execute statspack.modify_statspack_parameter(i_snap_level=>7);
  -- reconnect as sysdba - spcreate leaves us with perfstat
  conn / as sysdba
  grant select any table to perfstat;
  grant select any dictionary to perfstat;
  -- reconnect as perfstat to install the extensions
  conn perfstat/${PERFPWD}
  @${TMPFILE}
  SPOOL ${SPOOL}3.log
  variable jobno number;
  variable instno number;
  begin
    select instance_number into :instno from v\$instance;
    dbms_job.submit(:jobno, '${IZ_JOB}', trunc(sysdate+1/24,'HH'), 'trunc(SYSDATE+1/24,''HH'')', TRUE, :instno);
    commit;
  end;
/
  select job, next_date, next_sec
    from user_jobs
   where job = :jobno;
  SPOOL OFF
ENDSQL

cat ${SPOOL}2.log>>${SPOOL}1.log && rm ${SPOOL}2.log
cat ${SPOOL}3.log>>${SPOOL}1.log && rm ${SPOOL}3.log
mv ${SPOOL}1.log ${SPOOL}
rm -f ${TMPFILE}
