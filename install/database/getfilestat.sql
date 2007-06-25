-- ===========================================================================
-- Oracle StatsPack Report 2 Html    (c) 2003 by IzzySoft  (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Additional Procedure to collect information on growth of datafiles.
-- If you want to use this feature, run this script in e.g. SQL*Plus as
-- PERFSTAT (you need to GRANT SELECT ANY TABLE TO PERFSTAT first)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE get_fileinfo IS
 db_id NUMBER; instnum NUMBER; snapid NUMBER(6);
 CURSOR C_Get IS
  SELECT DISTINCT t.name tablespace,d.name datafile,d.bytes bytes,
         free.bytes bytes_free
    FROM v$datafile d,v$tablespace t,dba_free_space f,
         ( SELECT file_id,SUM(bytes) bytes
	     FROM dba_free_space
	    GROUP BY file_id ) free
   WHERE f.file_id = d.file#
     AND d.ts#=t.ts#
     AND free.file_id=d.file#;

BEGIN
 SELECT d.dbid,i.instance_number INTO db_id,instnum
   FROM v$database d,v$instance i;
 SELECT MAX(snap_id) INTO snapid
   FROM stats$snapshot
  WHERE dbid = db_id
    AND instance_number = instnum;
 FOR rec IN C_Get LOOP
  INSERT INTO istats$datafiles (snap_id,dbid,instance_number,tablespace,
              datafile,bytes,bytes_free)
		VALUES (snapid,db_id,instnum,rec.tablespace,rec.datafile,
		        rec.bytes,rec.bytes_free);
 END LOOP;
EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
END;
/
