-- ===========================================================================
-- Oracle StatsPack Report 2 Html    (c) 2003 by IzzySoft  (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Table for the additional Procedure to collect information on selected wait
-- objects (see getwaits.sql). Adjust the settings e.g. for the table space,
-- to reflect the settings of your database. This table should be created in
-- the schema of the perfstat user.
-- ---------------------------------------------------------------------------

CREATE TABLE ISTATS$WAITOBJECTS ( 
  SNAP_ID          NUMBER (6)
     CONSTRAINT WAITOBJECTS_NOTNULL_SNAPID   NOT NULL, 
  DBID             NUMBER
     CONSTRAINT WAITOBJECTS_NOTNULL_DBID   NOT NULL, 
  INSTANCE_NUMBER  NUMBER
     CONSTRAINT WAITOBJECTS_NOTNULL_INSTNUM   NOT NULL, 
  OWNER            VARCHAR2 (30)
     CONSTRAINT WAITOBJECTS_NOTNULL_OWNER   NOT NULL, 
  SEGMENT_NAME     VARCHAR2 (81)
     CONSTRAINT WAITOBJECTS_NOTNULL_SEGNAME   NOT NULL, 
  SEGMENT_TYPE     VARCHAR2 (18), 
  EVENT            VARCHAR2 (64)
     CONSTRAINT WAITOBJECTS_NOTNULL_EVENT   NOT NULL, 
  WAIT_TIME        NUMBER, 
  SECONDS_IN_WAIT  NUMBER)
   TABLESPACE TOOLS
   NOCACHE; 

ALTER TABLE ISTATS$WAITOBJECTS ADD  CONSTRAINT WAITOBJECTS_PK
 PRIMARY KEY (snap_id, dbid, instance_number, owner, segment_name, event);

ALTER TABLE ISTATS$WAITOBJECTS ADD  CONSTRAINT WAITOBJECTS_FK
 FOREIGN KEY (SNAP_ID, DBID, INSTANCE_NUMBER) 
  REFERENCES PERFSTAT.STATS$SNAPSHOT (SNAP_ID, DBID, INSTANCE_NUMBER) ON DELETE CASCADE;

GRANT SELECT ON ISTATS$WAITOBJECTS TO PUBLIC;
