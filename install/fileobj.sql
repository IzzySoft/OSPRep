-- ===========================================================================
-- Oracle StatsPack Report 2 Html    (c) 2003 by IzzySoft  (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Table for the additional Procedure to collect information growth of
-- datafiles. Adjust the settings e.g. for the table space,
 to reflect the
-- settings of your database. This table should be created in
 the schema of
-- the perfstat user.
-- ---------------------------------------------------------------------------

CREATE TABLE ISTATS$DATAFILES ( 
  SNAP_ID          NUMBER (6)
     CONSTRAINT DATAFILES_NOTNULL_SNAPID   NOT NULL, 
  DBID             NUMBER
     CONSTRAINT DATAFILES_NOTNULL_DBID   NOT NULL, 
  INSTANCE_NUMBER  NUMBER
     CONSTRAINT DATAFILES_NOTNULL_INSTNUM   NOT NULL, 
  TABLESPACE       VARCHAR2 (30)
     CONSTRAINT DATAFILES_NOTNULL_TS   NOT NULL, 
  DATAFILE     VARCHAR2 (513)
     CONSTRAINT DATAFILES_NOTNULL_DATAFILE   NOT NULL, 
  BYTES        NUMBER, 
  BYTES_FREE   NUMBER)
   TABLESPACE TOOLS
   NOCACHE; 

ALTER TABLE ISTATS$DATAFILES ADD  CONSTRAINT DATAFILES_FK
 FOREIGN KEY (SNAP_ID, DBID, INSTANCE_NUMBER) 
  REFERENCES PERFSTAT.STATS$SNAPSHOT (SNAP_ID, DBID, INSTANCE_NUMBER) ON DELETE CASCADE;

GRANT SELECT ON ISTATS$DATAFILES TO PUBLIC;
