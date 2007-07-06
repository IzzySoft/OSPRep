-- ===========================================================================
-- Oracle StatsPack Report 2 Html (c)2003-2005 by IzzySoft (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Additional Procedure to collect information on session statistics. Mainly
-- used to work around some bugs with v$sysstat without the need of running
-- statspack.snap() at level 10. Make sure to not use this procedure together
-- with level 10 snapshots -- otherwise you'll get strange stats :)
-- run this script in e.g. SQL*Plus as PERFSTAT. Then you may add it in your
-- statspack.snap() job *AFTER* the statspack.snap() call.
-- !!! DON'T USE THIS WITH ORACLE 10.2 OR LEVEL 10 SNAPSHOTS !!!
-- ---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE get_sesstat AUTHID DEFINER IS
 db_id NUMBER; instnum NUMBER; snapid NUMBER(6);
 CURSOR C_GetStat IS
  SELECT statistic# stat,sum(value) value
    FROM v$sesstat
   GROUP BY statistic#;
	
BEGIN
 SELECT d.dbid,i.instance_number INTO db_id,instnum
   FROM v$database d,v$instance i;
 SELECT MAX(snap_id) INTO snapid
   FROM stats$snapshot
  WHERE dbid = db_id
    AND instance_number = instnum;
 FOR RS IN C_GetStat LOOP
  INSERT INTO stats$sesstat (snap_id,dbid,instance_number,statistic#,value)
		VALUES (snapid,db_id,instnum,RS.stat,RS.value);
 END LOOP;
EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
END;
/
