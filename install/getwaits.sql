-- ===========================================================================
-- Oracle StatsPack Report 2 Html    (c) 2003 by IzzySoft  (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Additional Procedure to collect information on selected wait objects, i.e.
-- objects causing wait events. In order to successfully install and use this
-- procedure, make sure to GRANT SELECT ANY TABLE TO PERFSTAT first, and then
-- run this script in e.g.
 SQL*Plus as PERFSTAT
-- ---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE get_waitevents AUTHID DEFINER IS
 db_id NUMBER; instnum NUMBER; snapid NUMBER(6);
 CURSOR C_GetEvents IS
  SELECT a.owner,a.segment_name,a.segment_type,
         b.event,b.wait_time waited,b.seconds_in_wait seconds
    FROM ( SELECT p1 file#, p2 block#, event, wait_time, seconds_in_wait
             FROM v$session_wait
		    WHERE event IN ('buffer_busy_waits','db file sequential read',
		                    'db file scattered read','free buffer waits')
 		) b, dba_extents a
   WHERE a.file_id = b.file#
     AND b.block# BETWEEN a.block_id AND (a.block_id + blocks - 1);

BEGIN
 SELECT d.dbid,i.instance_number INTO db_id,instnum
   FROM v$database d,v$instance i;
 SELECT MAX(snap_id) INTO snapid
   FROM stats$snapshot
  WHERE dbid = db_id
    AND instance_number = instnum;
 FOR R_ev IN C_GetEvents LOOP
  INSERT INTO istats$waitobjects (snap_id,dbid,instance_number,owner,
              segment_name,segment_type,event,wait_time,seconds_in_wait)
		VALUES (snapid,db_id,instnum,R_ev.owner,R_ev.segment_name,
		        R_ev.segment_type,R_ev.event,R_ev.waited,R_ev.seconds);
 END LOOP;
EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
END;
/

