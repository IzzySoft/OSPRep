<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Enqueue Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Below you find a description on selected enqueue types:</P>
 <TABLE STYLE="border:0">
  <TR><TD CLASS="smallname">AB</TD>
      <TD CLASS="text"><B>ABMR</B>:<UL>
        <LI>Lock held to ensure that ABMR process is initialized</LI>
        <LI>Lock held to ensure that only one ABMR is started in the cluster</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">AD</TD>
      <TD CLASS="text"><B>Synchronizes accesses to a specific OSM</B> (Oracle Software Manager) disk AU</TD></TR>
  <TR><TD CLASS="smallname">AE</TD>
      <TD CLASS="text">Prevent Dropping an edition in use</TD></TR>
  <TR><TD CLASS="smallname">AF</TD>
      <TD CLASS="text"><B>Serializes access to an advisor task</B></TD></TR>
  <TR><TD CLASS="smallname">AG</TD>
      <TD CLASS="text"><B>Synchronizes generation use of a particular workspace</B></TD></TR>
  <TR><TD CLASS="smallname">AM</TD>
      <TD CLASS="text"><B>ASM group block</B></TD></TR>
  <TR><TD CLASS="smallname">AO</TD>
      <TD CLASS="text"><B>Synchronizes access to objects and scalar variables</B></TD></TR>
  <TR><TD CLASS="smallname">AS</TD>
      <TD CLASS="text"><B>Synchronizes new service activation</B></TD></TR>
  <TR><TD CLASS="smallname">AT</TD>
      <TD CLASS="text"><B>Serializes alter tablespace operations</B></TD></TR>
  <TR><TD CLASS="smallname">AW</TD>
      <TD CLASS="text"><B>AW$ table</B> (analytical workplace tables used in OLAP option)<UL>
        <LI><B>AW$ table lock:</B> Allows global access synchronization to the AW$ table</LI>
        <LI><B>AW generation lock:</B> Gives in-use generation state for a particular workspace</LI>
        <LI><B>user access for AW:</B> Synchronizes user accesses to a particular workspace</LI>
        <LI><B>AW state lock:</B> Row lock synchronization for the AW$ table</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">AY</TD>
      <TD CLASS="text"><B>AffinitY:</B> Affinity Dictionary test affinity synchronization</TD></TR>
  <TR><TD CLASS="smallname">BB</TD>
      <TD CLASS="text">2PC distributed transaction branch across RAC instances</TD></TR>
  <TR><TD CLASS="smallname">BF</TD>
      <TD CLASS="text"><B>Bloom Filter:</B> PMON bloom filter recovery</TD></TR>
  <TR><TD CLASS="smallname">BL</TD>
      <TD CLASS="text"><B>Buffer Cache Managment</B></TD></TR>
  <TR><TD CLASS="smallname">BR</TD>
      <TD CLASS="text"><B>Backup/Restore</B><UL>
        <LI><B>file shrink:</B> Lock held to prevent file from decreasing in physical size during RMAN backup</LI>
        <LI><B>proxy-copy:</B> Lock held to allow cleanup from backup mode during an RMAN proxy-copy backup</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">CF</TD>
      <TD CLASS="text"><B>Control file schema</B> global enqueue</TD></TR>
  <TR><TD CLASS="smallname">CI</TD>
      <TD CLASS="text"><B>Cross Instance</B> call invocation</TD></TR>
  <TR><TD CLASS="smallname">CL</TD>
      <TD CLASS="text"><B>Label Cache</B><UL>
        <LI><B>drop label:</B> Synchronizes accesses to label cache when dropping a label</LI>
        <LI><B>compare labels:</B> Synchronizes accesses to label cache for label comparison</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">CM</TD>
      <TD CLASS="text"><B>ASM diskgroup related</B></TD></TR>
  <TR><TD CLASS="smallname">CQ</TD>
      <TD CLASS="text"><B>Client Query:</B> Serializes access to cleanup client query cache registrations</TD></TR>
  <TR><TD CLASS="smallname">CT</TD>
      <TD CLASS="text"><B>Change Tracking</B><UL>
        <LI><B>CTWR process start/stop:</B> Lock held to ensure that only one CTWR (Change Tracking Writer, which tracks block changes and is initiated by the alter database enable block change tracking command) process is started in a single instance</LI>
        <LI><B>change stream ownership:</B> Lock held by one instance while change tracking is enabled to guarantee access to thread-specific resources</LI>
        <LI><B>global space management:</B> Lock held during change tracking space management operations that affect the entire change tracking file</LI>
        <LI><B>local space management:</B> Lock held during change tracking space management operations that affect just the data for one thread</LI>
        <LI><B>reading:</B> Lock held to ensure that change tracking data remains in existence until a reader is done with it</LI>
        <LI><B>state:</B> Lock held while enabling or disabling change tracking to ensure that it is enabled or disabled by only one user at a time</LI>
        <LI><B>state change gate 1/2:</B> Lock held while enabling or disabling change tracking in RAC</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">CU</TD>
      <TD CLASS="text"><B>Cursor Bind:</B> Recovers cursors in case of death while compiling</TD></TR>
  <TR><TD CLASS="smallname">CX</TD>
      <TD CLASS="text"><B>CtX Index:</B> Index Specific Lock on CTX index</TD></TR>
  <TR><TD CLASS="smallname">DB</TD>
      <TD CLASS="text"><B>Synchronizes modification of database wide supplemental logging attributes</B></TD></TR>
  <TR><TD CLASS="smallname">DD</TD>
      <TD CLASS="text"><B>Synchronizes local accesses to ASM (Automatic Storage Management) disk groups</B></TD></TR>
  <TR><TD CLASS="smallname">DF</TD>
      <TD CLASS="text"><B>Datafile:</B> Enqueue held by foreground or DBWR when a datafile is brought online in RAC</TD></TR>
  <TR><TD CLASS="smallname">DG</TD>
      <TD CLASS="text"><B>Synchronizes accesses to ASM disk groups</B></TD></TR>
  <TR><TD CLASS="smallname">DL</TD>
      <TD CLASS="text"><B>Direct Loader</B> index creation (Lock to prevent index DDL during direct load)</TD></TR>
  <TR><TD CLASS="smallname">DM</TD>
      <TD CLASS="text"><B>Database Mount:</B> Enqueue held by foreground or DBWR to synchronize database mount/open with other operations</TD></TR>
  <TR><TD CLASS="smallname">DN</TD>
      <TD CLASS="text"><B>Serializes group number generations</B></TD></TR>
  <TR><TD CLASS="smallname">DO</TD>
      <TD CLASS="text"><B>Disk Online Operation</B></TD></TR>
  <TR><TD CLASS="smallname">DP</TD>
      <TD CLASS="text"><B>Synchronizes access to LDAP parameters</B></TD></TR>
  <TR><TD CLASS="smallname">DR</TD>
      <TD CLASS="text"><B>Distributed Recovery:</B> Serializes the active distributed recovery operation</TD></TR>
  <TR><TD CLASS="smallname">DS</TD>
      <TD CLASS="text"><B>Prevents a database suspend during LMON reconfiguration</B></TD></TR>
  <TR><TD CLASS="smallname">DT</TD>
      <TD CLASS="text"><B>Serializes changing the default temporary table space and user creation</B></TD></TR>
  <TR><TD CLASS="smallname">DV</TD>
      <TD CLASS="text"><B>Synchronizes access to lower-version Diana (PL/SQL intermediate representation)</B></TD></TR>
  <TR><TD CLASS="smallname">DW</TD>
      <TD CLASS="text">Serialize in memory dispenser operations</TD></TR>
  <TR><TD CLASS="smallname">DX</TD>
      <TD CLASS="text"><B>Distributed Transactions:</B> Serializes tightly coupled distributed transaction branches</TD></TR>
  <TR><TD CLASS="smallname">FA</TD>
      <TD CLASS="text"><B>File Access:</B> Synchronizes accesses to open ASM files</TD></TR>
  <TR><TD CLASS="smallname">FB</TD>
      <TD CLASS="text"><B>File Blocks:</B> Ensures that only one process can format data blocks in auto segment space managed tablespaces</TD></TR>
  <TR><TD CLASS="smallname">FC</TD>
      <TD CLASS="text"><UL>
        <LI><B>open an ACD thread:</B> LGWR opens an ACD thread</LI>
        <LI><B>recover an ACD thread:</B> SMON recovers an ACD thread</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">FD</TD>
      <TD CLASS="text"><B>Synchronization</B></TD></TR>
  <TR><TD CLASS="smallname">FG</TD>
      <TD CLASS="text"><UL>
        <LI><B>serialize ACD relocate:</B> Only 1 process in the cluster may do ACD relocation in a disk group</LI>
        <LI><B>LGWR redo generation enq race:</B> Resolves race condition to acquire Disk Group Redo Generation Enqueue</LI>
        <LI><B>FG redo generation enq race:</B> Resolves race condition to acquire Disk Group Redo Generation Enqueue</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">FL</TD>
      <TD CLASS="text"><B>Flashback Database Log</B><UL>
        <LI><B>Flashback database log:</B> Synchronizes access to Flashback database log</LI>
        <LI><B>Flashback db command:</B> Synchronizes Flashback Database and deletion of flashback logs</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">FM</TD>
      <TD CLASS="text"><B>File Mapping:</B> Synchronizes access to global file mapping state</TD></TR>
  <TR><TD CLASS="smallname">FP</TD>
      <TD CLASS="text">Synchronizes various File Object(FOB) operations</TD></TR>
  <TR><TD CLASS="smallname">FR</TD>
      <TD CLASS="text"><B>File Recovery:</B> Begins recovery of disk group</TD></TR>
  <TR><TD CLASS="smallname">FS</TD>
      <TD CLASS="text"><B>File Set:</B> Synchronizes recovery and file operations or synchronizes dictionary check</TD></TR>
  <TR><TD CLASS="smallname">FT</TD>
      <TD CLASS="text"><B>File Thread:</B><UL>
        <LI><B>allow LGWR writes:</B> Allows LGWR to generate redo in this thread</LI>
        <LI><B>disable LGWR writes:</B> Prevents LGWR from generating redo in this thread</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">FU</TD>
      <TD CLASS="text"><B>File Usage:</B>   Serializes the capture of the DB feature, usage, and high watermark statistics</TD></TR>
  <TR><TD CLASS="smallname">FX</TD>
      <TD CLASS="text">ARB relocates ACD extent</TD></TR>
  <TR><TD CLASS="smallname">HD</TD>
      <TD CLASS="text">Serializes accesses to ASM SGA data structures</TD></TR>
  <TR><TD CLASS="smallname">HP</TD>
      <TD CLASS="text">Synchronizes accesses to queue pages</TD></TR>
  <TR><TD CLASS="smallname">HQ</TD>
      <TD CLASS="text">Synchronizes the creation of new queue IDs</TD></TR>
  <TR><TD CLASS="smallname">HV</TD>
      <TD CLASS="text" ROWSPAN="2"><B>High Water Mark:</B> Lock used to broker the high watermark during parallel inserts (manually allocating extents can
          circumvent this wait)</TD></TR>
  <TR><TD CLASS="smallname">HW</TD></TR>
  <TR><TD CLASS="smallname">HW</TD>
      <TD CLASS="text"><B>Space Management</B> operations on a specific
          segment. This enqueue is used to serialize the allocation of space
          above the high water mark of a segment:<BR>
          <CODE>V$SESSION_WAIT.P2 / V$LOCK.ID1</CODE> is the tablespace number<BR>
          <CODE>V$SESSION_WAIT.P2 / V$LOCK.ID2</CODE> is the relative dba segment
          header of the object for which space is being allocated<BR>
          If this is a point of contention for an object, then manual allocation
          of extents solves the problem.</TD></TR>
  <TR><TD CLASS="smallname">ID</TD>
      <TD CLASS="text">Lock held to prevent other processes from performing controlfile transaction while NID is running</TD></TR>
  <TR><TD CLASS="smallname">IL</TD>
      <TD CLASS="text"><B>Internal Label:</B> Synchronizes accesses to internal label data structures</TD></TR>
  <TR><TD CLASS="smallname">IM</TD>
      <TD CLASS="text">Serializes block recovery for IMU txn</TD></TR>
  <TR><TD CLASS="smallname">IN</TD>
      <TD CLASS="text"><B>Instance Number</B></TD></TR>
  <TR><TD CLASS="smallname">IR</TD>
      <TD CLASS="text"><B>Instance Recovery</B><UL>
        <LI><B>contention:</B> Synchronizes instance recovery</LI>
        <LI><B>contention2:</B> Synchronizes parallel instance recovery and shutdown immediate</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">IS</TD>
      <TD CLASS="text"><B>Instance State</B></TD></TR>
  <TR><TD CLASS="smallname">IT</TD>
      <TD CLASS="text"><B>Instance Temporary:</B> Synchronizes accesses to a temp object’s metadata</TD></TR>
  <TR><TD CLASS="smallname">IV</TD>
      <TD CLASS="text"><B>Library Cache Invalidation</B></TD></TR>
  <TR><TD CLASS="smallname">JD</TD>
      <TD CLASS="text">Job Syncrhonization (Dates)</TD></TR>
  <TR><TD CLASS="smallname">JI</TD>
      <TD CLASS="text">Enqueue used during AJV snapshot refresh</TD></TR>
  <TR><TD CLASS="smallname">JQ</TD>
      <TD CLASS="text"><B>Job Queue</B></TD></TR>
  <TR><TD CLASS="smallname">JS</TD>
      <TD CLASS="text"><B>Job Synchronization</B><UL>
        <LI><B>contention:</B> Synchronizes accesses to the job cache</LI>
        <LI><B>coord post lock:</B> Lock for coordinator posting</LI>
        <LI><B>coord rcv lock:</B> Lock when coord receives msg</LI>
        <LI><B>global wdw lock:</B> Lock acquired when doing wdw ddl</LI>
        <LI><B>job chain evaluate lock:</B> Lock when job chain evaluated for steps to create</LI>
        <LI><B>job recov lock:</B> Lock to recover jobs running on crashed RAC inst</LI>
        <LI><B>job run lock – synchronize:</B> Lock to prevent job from running elsewhere</LI>
        <LI><B>q mem clnup lck:</B> Lock obtained when cleaning up q memory</LI>
        <LI><B>queue lock:</B> Lock on internal scheduler queue</LI>
        <LI><B>running job cnt lock:</B> Lock to get running job count</LI>
        <LI><B>running job cnt lock2:</B> Lock to set running job count epre</LI>
        <LI><B>running job cnt lock3:</B> Lock to set running job count epost</LI>
        <LI><B>slave enq get lock1:</B> Slave locks exec pre to sess strt</LI>
        <LI><B>slave enq get lock2:</B> Gets run info locks before slv objget</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">JX</TD>
      <TD CLASS="text">release SQL statement resources</TD></TR>
  <TR><TD CLASS="smallname">KD</TD>
      <TD CLASS="text">Determine DBRM master</TD></TR>
  <TR><TD CLASS="smallname">KK</TD>
      <TD CLASS="text"><B>Redo Log "Kick":</B> Lock held by open redo thread, used by other instances to force a log switch</TD></TR>
  <TR><TD CLASS="smallname">KM</TD>
      <TD CLASS="text">Synchronizes various Resource Manager operations</TD></TR>
  <TR><TD CLASS="smallname">KO</TD>
      <TD CLASS="text">Coordinates fast object checkpoint</TD></TR>
  <TR><TD CLASS="smallname">KP</TD>
      <TD CLASS="text"><B>Kupp Process:</B> Synchronizes kupp process startup</TD></TR>
  <TR><TD CLASS="smallname">KQ</TD>
      <TD CLASS="text">Synchronization of ASM cached attributes</TD></TR>
  <TR><TD CLASS="smallname">KT</TD>
      <TD CLASS="text">Synchronizes accesses to the current Resource Manager plan</TD></TR>
  <TR><TD CLASS="smallname">LA..LP</TD>
      <TD CLASS="text"><B>Library Cache</B> Lock</TD></TR>
  <TR><TD CLASS="smallname">LS</TD>
      <TD CLASS="text"><B>Log Start or Log Switch</B></TD></TR>
  <TR><TD CLASS="smallname">MD</TD>
      <TD CLASS="text"><B>Materialized Views:</B> enqueue for change data
          capture materialized view log (gotten internally for DDL on a
          snapshot log); id1=object# of the snapshot log.</TD></TR>
  <TR><TD CLASS="smallname">MH</TD>
      <TD CLASS="text"><B>Mail Host:</B> Lock used for recovery when setting Mail Host for AQ e-mail notifications</TD></TR>
  <TR><TD CLASS="smallname">MK</TD>
      <TD CLASS="text">changing values in enc$</TD></TR>
  <TR><TD CLASS="smallname">ML</TD>
      <TD CLASS="text"><B>MaiL:</B> Lock used for recovery when setting Mail Port for AQ e-mail notifications</TD></TR>
  <TR><TD CLASS="smallname">MM</TD>
      <TD CLASS="text"><B>Mount Definition</B></TD></TR>
  <TR><TD CLASS="smallname">MN</TD>
      <TD CLASS="text"><B>LogMiner:</B> Synchronizes updates to the LogMiner dictionary and prevents multiple instances from preparing the same LogMiner session</TD></TR>
  <TR><TD CLASS="smallname">MO</TD>
      <TD CLASS="text"><B>MMON:</B> Serialize MMON operations for restricted sessions</TD></TR>
  <TR><TD CLASS="smallname">MR</TD>
      <TD CLASS="text"><B>Media Recovery:</B> Lock used to coordinate media recovery with other uses of datafiles</TD></TR>
  <TR><TD CLASS="smallname">MS</TD>
      <TD CLASS="text"><B>Materialized view refreSh:</B> Lock held during materialized view refresh to set up MV log</TD></TR>
  <TR><TD CLASS="smallname">MV</TD>
      <TD CLASS="text"><B>Online Move:</B> Held during online datafile move operation or cleanup</TD></TR>
  <TR><TD CLASS="smallname">MW</TD>
      <TD CLASS="text"><B>Maintenance Window:</B> Serializes the calibration of the manageability schedules with the Maintenance Window</TD></TR>
  <TR><TD CLASS="smallname">MX</TD>
      <TD CLASS="text">Lock held to generate a response to the storage server information request when an instance is starting up</TD></TR>
  <TR><TD CLASS="smallname">NA..NZ</TD>
      <TD CLASS="text"><B>Library Cache</B> Pin</TD></TR>
  <TR><TD CLASS="smallname">OC</TD>
      <TD CLASS="text"><B>Outline Cache:</B> Synchronizes write accesses to the outline cache</TD></TR>
  <TR><TD CLASS="smallname">OD</TD>
      <TD CLASS="text">Lock to prevent concurrent online DDLs</TD></TR>
  <TR><TD CLASS="smallname">OL</TD>
      <TD CLASS="text"><B>OutLine:</B> Synchronizes accesses to a particular outline name</TD></TR>
  <TR><TD CLASS="smallname">OQ</TD>
      <TD CLASS="text"><UL>
        <LI><B>xsoqhiAlloc:</B> Synchronizes access to olapi history allocation</LI>
        <LI><B>xsoqhiClose:</B> Synchronizes access to olapi history closing</LI>
        <LI><B>xsoqhistrecb:</B> Synchronizes access to olapi history globals</LI>
        <LI><B>Synchronizes access to olapi history globals:</B> Synchronizes access to olapi history flushing</LI>
        <LI><B>xsoq*histrecb:</B> Synchronizes access to olapi history parameter CB</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">OT</TD>
      <TD CLASS="text">CTX Generic Locks</TD></TR>
  <TR><TD CLASS="smallname">OW</TD>
      <TD CLASS="text">Initialize/Terminate Wallet context</TD></TR>
  <TR><TD CLASS="smallname">PD</TD>
      <TD CLASS="text">Prevents others from updating the same property</TD></TR>
  <TR><TD CLASS="smallname">PE</TD>
      <TD CLASS="text">Synchronizes system parameter updates (<CODE>ALTER SYSTEM SET PARAMETER = VALUE</CODE>)</TD></TR>
  <TR><TD CLASS="smallname">PF</TD>
      <TD CLASS="text"><B>Password File</B></TD></TR>
  <TR><TD CLASS="smallname">PG</TD>
      <TD CLASS="text"><B>Parameter Global:</B> Synchronizes global system parameter updates</TD></TR>
  <TR><TD CLASS="smallname">PH</TD>
      <TD CLASS="text"><B>HTTP:</B> Lock used for recovery when setting proxy for AQ HTTP notifications</TD></TR>
  <TR><TD CLASS="smallname">PI</TD>
      <TD CLASS="text"><B>Parallel Slaves:</B>  Communicates remote Parallel Execution Server Process creation status</TD></TR>
  <TR><TD CLASS="smallname">PL</TD>
      <TD CLASS="text"><B>PLug-in ops:</B> Coordinates plug-in operation of transportable tablespaces</TD></TR>
  <TR><TD CLASS="smallname">PR</TD>
      <TD CLASS="text"><B>Process Startup</B></TD></TR>
  <TR><TD CLASS="smallname">PS</TD>
      <TD CLASS="text"><B>Parallel Slave Synchronization</B></TD></TR>
  <TR><TD CLASS="smallname">PT</TD>
      <TD CLASS="text">Synchronizes access to ASM PST metadata</TD></TR>
  <TR><TD CLASS="smallname">PV</TD>
      <TD CLASS="text"><UL>
        <LI><B>syncstart:</B> Synchronizes slave start_shutdown</LI>
        <LI><B>syncshut:</B> Synchronizes instance shutdown_slvstart</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">PW</TD>
      <TD CLASS="text"><B>PreWarmed Buffers:</B><UL>
        <LI><B>prewarm status in dbw0:</B> DBWR0 holds this enqueue indicating pre-warmed buffers present in cache</LI>
        <LI><B>flush prewarm buffers:</B> Direct Load needs to flush prewarmed buffers if DBWR0 holds this enqueue</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">QA..QZ</TD>
      <TD CLASS="text"><B>Row Cache</B></TD></TR>
  <TR><TD CLASS="smallname">RB</TD>
      <TD CLASS="text"><B>RollBack:</B> Serializes OSM rollback recovery operations</TD></TR>
  <TR><TD CLASS="smallname">RC</TD>
      <TD CLASS="text">Coordinates access to a result-set</TD></TR>
  <TR><TD CLASS="smallname">RD</TD>
      <TD CLASS="text">update RAC load info</TD></TR>
  <TR><TD CLASS="smallname">RE</TD>
      <TD CLASS="text">Synchronize block repair/resilvering operations</TD></TR>
  <TR><TD CLASS="smallname">RF</TD>
      <TD CLASS="text"><UL>
        <LI><B>synch: per-SGA Broker metadata:</B> Ensures r/w atomicity of DG configuration metadata per unique SGA</LI>
        <LI><B>synchronization: critical ai:</B> Synchronizes critical apply instance among primary instances</LI>
        <LI><B>new AI:</B> Synchronizes selection of the new apply instance</LI>
        <LI><B>synchronization: chief:</B> Anoints 1 instance’s DMON (Data Guard Broker Monitor) as chief to other instance’s DMONs</LI>
        <LI><B>synchronization: HC master:</B> Anoints 1 instance’s DMON as health check master</LI>
        <LI><B>synchronization: aifo master:</B> Synchronizes critical apply instance failure detection and failover operation</LI>
        <LI><B>atomicity:</B> Ensures atomicity of log transport setup</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">RK</TD>
      <TD CLASS="text">wallet master key rekey</TD></TR>
  <TR><TD CLASS="smallname">RL</TD>
      <TD CLASS="text"><B>RAC wallet Lock</B></TD></TR>
  <TR><TD CLASS="smallname">RN</TD>
      <TD CLASS="text">Coordinates nab computations of online logs during recovery</TD></TR>
  <TR><TD CLASS="smallname">RO</TD>
      <TD CLASS="text"><B>Object Reuse</B><UL>
        <LI><B>contention:</B> Coordinates flushing of multiple objects</LI>
        <LI><B>fast object reuse:</B> Coordinates fast object reuse</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">RP</TD>
      <TD CLASS="text"><B>Repair:</B>   Enqueue held when resilvering is needed or when data block is repaired from mirror</TD></TR>
  <TR><TD CLASS="smallname">RR</TD>
      <TD CLASS="text">Concurrent invocation of <CODE>DBMS_WORKLOAD_*</CODE> package API</TD></TR>
  <TR><TD CLASS="smallname">RS</TD>
      <TD CLASS="text"><B>Reclaim Space:</B><UL>
        <LI><B>file delete:</B> Lock held to prevent file from accessing during space reclamation</LI>
        <LI><B>persist alert level:</B> Lock held to make alert level persistent</LI>
        <LI><B>write alert level:</B> Lock held to write alert level</LI>
        <LI><B>read alert level:</B> Lock held to read alert level</LI>
        <LI><B>prevent aging list update:</B> prevent aging list update</LI>
        <LI><B>record reuse:</B> Lock held to prevent file from accessing while reusing circular record</LI>
        <LI><B>prevent file delete:</B> Lock held to prevent deleting file to reclaim space</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">RT</TD>
      <TD CLASS="text"><B>Redo Thread Log:</B> Thread locks held by LGWR, DBW0, and RVWR (Recovery Writer, used in Flashback Database operations) to indicate mounted or open status</TD></TR>
  <TR><TD CLASS="smallname">RU</TD>
      <TD CLASS="text">Serializes rolling migration operations</TD></TR>
  <TR><TD CLASS="smallname">RW</TD>
      <TD CLASS="text"><B>Row Wait</B></TD></TR>
  <TR><TD CLASS="smallname">RX</TD>
      <TD CLASS="text"><B>ASM Extents</B></TD></TR>
  <TR><TD CLASS="smallname">SB</TD>
      <TD CLASS="text"><B>StandBy</B>: Synchronizes logical standby metadata operations</TD></TR>
  <TR><TD CLASS="smallname">SC</TD>
      <TD CLASS="text"><B>System Commit Number</B></TD></TR>
  <TR><TD CLASS="smallname">SE</TD>
      <TD CLASS="text">Synchronizes transparent session migration operations</TD></TR>
  <TR><TD CLASS="smallname">SF</TD>
      <TD CLASS="text">Lock held for recovery when setting sender for AQ e-mail notifications</TD></TR>
  <TR><TD CLASS="smallname">SH</TD>
      <TD CLASS="text">Enqueue always acquired in no-wait mode – should seldom see this contention</TD></TR>
  <TR><TD CLASS="smallname">SI</TD>
      <TD CLASS="text">Prevents multiple streams table instantiations</TD></TR>
  <TR><TD CLASS="smallname">SJ</TD>
      <TD CLASS="text">Serializes cancelling task executed by slave process</TD></TR>
  <TR><TD CLASS="smallname">SK</TD>
      <TD CLASS="text"><B>ShrinK:</B> Serialize shrink of a segment</TD></TR>
  <TR><TD CLASS="smallname">SL</TD>
      <TD CLASS="text"><B>Sending Lock</B> request/escalate to LCK0</TD></TR>
  <TR><TD CLASS="smallname">SM</TD>
      <TD CLASS="text"><B>SMon</B></TD></TR>
  <TR><TD CLASS="smallname">SN</TD>
      <TD CLASS="text"><B>Sequence Number</B></TD></TR>
  <TR><TD CLASS="smallname">SO</TD>
      <TD CLASS="text"><B>Shared Object:</B> Synchronizes access to Shared Object (PL/SQL Shared Object Manager)</TD></TR>
  <TR><TD CLASS="smallname">SQ</TD>
      <TD CLASS="text"><B>SeQuences</B> not being cached, having a to small
          cache size or being aged out of the shared pool. Consider pinning
          sequences or increasing the shared_pool_size.</TD></TR>
  <TR><TD CLASS="smallname">SR</TD>
      <TD CLASS="text"><B>Synchronized Replication</B></TD></TR>
  <TR><TD CLASS="smallname">SS</TD>
      <TD CLASS="text"><B>Sort Segment:</B> Ensures that sort segments created during parallel DML operations aren’t prematurely cleaned up</TD></TR>
  <TR><TD CLASS="smallname">ST</TD>
      <TD CLASS="text"><B>Space management locks</B> could be caused by using
          permanent tablespaces for sorting (rather than temporary), or by
          dynamic allocation resulting from inadequate storage clauses (only
          with Dictionary Managed TableSpaces). In the latter case, using
          locally-managed tablespaces may help avoiding this problem. If this
          is not an option for some reason, you may at least change the next
          extent sizes of the growing objects to be large enough to avoid
          constant space allocation. To determine which segments are growing
          constantly, monitor the <CODE>EXTENTS</CODE> column of the
          <CODE>DBA_SEGMENTS</CODE> view for all <CODE>SEGMENT_NAME</CODE>s
          over time to identify which segments are growing and how quickly.
          Also, you may pre-allocate space in the regarding segment.<BR>
          For the first case, the solution is quite obvious: check whether
          the temporary tablespace uses <CODE>TEMPFILES</CODE> and whether
          the temporary tablespace for the users is set correctly (at least
          up to Oracle 8i, if you didn't specify it explicitly it was set
          to SYSTEM!).</TD></TR>
  <TR><TD CLASS="smallname">SU</TD>
      <TD CLASS="text"><B>SaveUndo:</B> Serializes access to SaveUndo Segment</TD></TR>
  <TR><TD CLASS="smallname">SV</TD>
      <TD CLASS="text"><B>Sequence Number Value</B></TD></TR>
  <TR><TD CLASS="smallname">SW</TD>
      <TD CLASS="text">Coordinates the ‘alter system suspend’ operation</TD></TR>
  <TR><TD CLASS="smallname">TA</TD>
      <TD CLASS="text"><B>Transaction Recovery:</B> Serializes operations on undo segments and undo tablespaces</TD></TR>
  <TR><TD CLASS="smallname">TB</TD>
      <TD CLASS="text"><B>Tuning Base:</B> Synchronizes writes to the SQL Tuning Base Existence Cache</TD></TR>
  <TR><TD CLASS="smallname">TC</TD>
      <TD CLASS="text"><B>Thread Checkpoint:</B><UL>
        <LI><B>contention:</B> Lock held to guarantee uniqueness of a tablespace checkpoint</LI>
        <LI><B>contention2:</B> Lock during setup of a unique tablespace checkpoint in null mode</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">TD</TD>
      <TD CLASS="text">KTF dumping time/scn mappings in SMON_SCN_TIME table</TD></TR>
  <TR><TD CLASS="smallname">TE</TD>
      <TD CLASS="text"><B>Extend Table</B></TD></TR>
  <TR><TD CLASS="smallname">TF</TD>
      <TD CLASS="text"><B>Temporary File:</B> Serializes dropping of a temporary file</TD></TR>
  <TR><TD CLASS="smallname">TH</TD>
      <TD CLASS="text">Serializes threshold in-memory chain access</TD></TR>
  <TR><TD CLASS="smallname">TK</TD>
      <TD CLASS="text"><B>Autotask Slave</B></TD></TR>
  <TR><TD CLASS="smallname">TL</TD>
      <TD CLASS="text">Serializes threshold log table read and update</TD></TR>
  <TR><TD CLASS="smallname">TM</TD>
      <TD CLASS="text"><B>Table locks</B> point to the possibility of e.g.
          foreign key constraints not being indexed</TD></TR>
  <TR><TD CLASS="smallname">TO</TD>
      <TD CLASS="text"><B>Temporary Table Object Enqueue</B></TD></TR>
  <TR><TD CLASS="smallname">TP</TD>
      <TD CLASS="text">Lock held during purge and dynamic reconfiguration of fixed tables.</TD></TR>
  <TR><TD CLASS="smallname">TQ</TD>
      <TD CLASS="text"><B>Queue Table:</B><UL>
        <LI><B>TM contention:</B> TM access to the queue table</LI>
        <LI><B>DDL contention:</B> DDL access to the queue table</LI>
        <LI><B>INI contention:</B> TM access to the queue table</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">TS</TD>
      <TD CLASS="text"><B>Temporary Segment</B></TD></TR>
  <TR><TD CLASS="smallname">TT</TD>
      <TD CLASS="text"><B>Temporary Table</B></TD></TR>
  <TR><TD CLASS="smallname">TW</TD>
      <TD CLASS="text"><B>Transaction Wait:</B> Lock held by one instance to wait for transactions on all instances to finish</TD></TR>
  <TR><TD CLASS="smallname">TX</TD>
      <TD CLASS="text"><B>Transaction locks</B> indicate multiple users try
          modifying the same row of a table (row-level-lock) or a row that is
          covered by the same bitmap index fragment, or a session is waiting
          for an ITL (interested transaction list) slot in a block, but one or
          more sessions have rows locked in the same block, and there is no
          free ITL slot in the block. In the first case, the first user has to
          <CODE>COMMIT</CODE> or <CODE>ROLLBACK</CODE> to solve the problem. In
          the second case, increasing the number of ITLs available is the
          answer - which can be done by changing either the
          <A HREF="initrans.html"><CODE>INITRANS</CODE> or <CODE>MAXTRANS</CODE></A>
          for the table in question, or make the block smaller by using smaller
          block sizes (or increasing pctfree).<BR>
          Another issue involves duplicates in an unique index; freeing this
          enqueue requires commit/rollback when multiple users try to modify
          the same segment.<UL>
            <LI><B>allocate ITL entry:</B> Allocating an ITL entry in order to begin a transaction</LI>
            <LI><B>contention:</B> Lock held by a transaction to allow other transactions to wait for it</LI>
            <LI><B>index contention:</B> Lock held on an index during a split to prevent other operations on it</LI>
            <LI><B>row lock contention:</B> Lock held on a particular row by a transaction to prevent other transactions from modifying it</LI>
          </UL></TD></TR>
  <TR><TD CLASS="smallname">UL</TD>
      <TD CLASS="text"><B>User-defined Locks</B></TD></TR>
  <TR><TD CLASS="smallname">UN</TD>
      <TD CLASS="text"><B>User Name</B></TD></TR>
  <TR><TD CLASS="smallname">US</TD>
      <TD CLASS="text"><B>Undo Segment</B>, serialization (Lock held to perform DDL on the undo segment)</TD></TR>
  <TR><TD CLASS="smallname">WA</TD>
      <TD CLASS="text"><B>Watermark AQ:</B> Lock used for recovery when setting watermark for memory usage in AQ notifications</TD></TR>
  <TR><TD CLASS="smallname">WF</TD>
      <TD CLASS="text">Enqueue used to serialize the flushing of snapshots</TD></TR>
  <TR><TD CLASS="smallname">WG</TD>
      <TD CLASS="text">Acquire lobid local enqueue when deleting/locking fso</TD></TR>
  <TR><TD CLASS="smallname">WL</TD>
      <TD CLASS="text"><B>Being Written Redo Log:</B> Coordinates access to redo log files and archive logs</TD></TR>
  <TR><TD CLASS="smallname">WM</TD>
      <TD CLASS="text">Synchronizes new WLM Plan activation</TD></TR>
  <TR><TD CLASS="smallname">WP</TD>
      <TD CLASS="text">Enqueue to handle concurrency between purging and baselines</TD></TR>
  <TR><TD CLASS="smallname">WR</TD>
      <TD CLASS="text">Coordinates access to logs by Async LNS and ARCH/FG</TD></TR>
  <TR><TD CLASS="smallname">XA</TD>
      <TD CLASS="text"><B>Instance Attribute Lock</B></TD></TR>
  <TR><TD CLASS="smallname">XC</TD>
      <TD CLASS="text">Lock obtained when incrementing XDB configuration version number</TD></TR>
  <TR><TD CLASS="smallname">XD</TD>
      <TD CLASS="text"><B>ExaData</B></TD></TR>
  <TR><TD CLASS="smallname">XH</TD>
      <TD CLASS="text">Lock used for recovery when setting No Proxy Domains for AQ HTTP notifications</TD></TR>
  <TR><TD CLASS="smallname">XI</TD>
      <TD CLASS="text"><B>Instance Registration Lock</B></TD></TR>
  <TR><TD CLASS="smallname">XL</TD>
      <TD CLASS="text">Keep multiple processes from faulting in the same extent chunk</TD></TR>
  <TR><TD CLASS="smallname">XR</TD>
      <TD CLASS="text"><UL>
        <LI><B>quiesce database:</B> Lock held during database quiesce</LI>
        <LI><B>database force logging:</B> Lock held during database force logging mode</LI>
      </UL></TD></TR>
  <TR><TD CLASS="smallname">XY</TD>
      <TD CLASS="text">Lock used by Oracle Corporation for internal testing</TD></TR>
  <TR><TD CLASS="smallname">ZA</TD>
      <TD CLASS="text">Lock held to add partition to std audit table</TD></TR>
  <TR><TD CLASS="smallname">ZF</TD>
      <TD CLASS="text">lock held to add partition to fga audit table</TD></TR>
  <TR><TD CLASS="smallname">ZG</TD>
      <TD CLASS="text">Coordinates file group operations</TD></TR>
  <TR><TD CLASS="smallname">ZH</TD>
      <TD CLASS="text">Synchronizes analysis and insert into compression$, prevents multiple threads analyzing the same table during a load</TD></TR>
  <TR><TD CLASS="smallname">ZZ</TD>
      <TD CLASS="text">lock held for updating global context hash tables</TD></TR>
 </TABLE>
 <P>For more information on enqueue waits, see <A HREF="enqueue.html">Enqueues</A>.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
