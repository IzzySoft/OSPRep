<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Instance Activity</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Introduction</H3>
 <P>These values are read and evaluated from the <code>stats$sysstat</code>
  table. In the original StatsPack package, the report just reads all data
  belonging to the start and end snapshots and sets them in relation (i.e.
  the values belonging to the same event: the start value will be substracted
  from the end value to obtain the difference, which is then used for the
  calculations).</P>
 <P>It is quite obvious, that not all values in this table make sense. Just
  to pick some examples: what does <code>change write time</code> per second
  mean (or any other time per second)? Moreover, all the timed values have a
  different base: some are in seconds, some in 1/100 seconds, others are even
  in 1/10 milliseconds...</P>
 <P>Since this report is derived from the original StatsPack report, we tend
  to make the same stupid stuff and read <b><i>all</i></b> data from this
  table, for at least two reasons: first we want to be sure to catch all
  useful values for all Oracle versions, and second the overhead of separating
  the data would be larger then the use of it. But in order to help you to
  distinguish the one from the other, the following list gives all events
  known to me together with a short explanation, if available.</P>

 <H3>Events and explanations</H3>
 <P>
  <B><CODE>CPU used by this session</CODE></B>: the term "this session" is
     misleading; this statistic applies to "all sessions". It is the amount of
     CPU time (in 10s of milliseconds) used between when a user call started
     and ended. Since some events are done in shorter time, 0 ms are added to
     the statistics in those cases.<BR>
  <B><CODE>CR blocks created</CODE></B>: A buffer in the buffer cache was cloned.
     The most common reason for cloning is that the buffer is held in an
     incompatible mode.<BR>
  <B><CODE>DBWR buffers scanned</CODE></B>: The total number of buffers looked
     at when scanning each LRU set for dirty buffers to clean. This count
     includes both dirty and clean buffers. Divide by DBWR LRU scans to find
     the average number of buffers scanned.<BR>
  <B><CODE>DBWR checkpoint buffers written</CODE></B>: The number of buffers
     that were written for checkpoints.<BR>
  <B><CODE>DBWR checkpoints</CODE></B>: Number of times the DBWR was asked to
     scan the cache and write all blocks marked for a checkpoint.<BR>
  <B><CODE>DBWR free buffers found</CODE></B>: The number of buffers that the
     DBWR found clean when it was requested to make free buffers. Divide by
     <CODE>DBWR make free requests</CODE> to find the average number of reusable
     buffers at the end of each LRU.<BR>
  <B><CODE>DBWR lru scans</CODE></B>: The number of times that the DBWR does a
     scan of the LRU queue looking for buffers to write. This includes times
     when the scan is to fill a batch being written for another purpose, such as
     a checkpoint. This statistic is always greater than or equal to <CODE>DBWR
     make free requests</CODE>.<BR>
  <B><CODE>DBWR make free requests</CODE></B>: Number of messages received
     requesting DBWR to make some more free buffers for the LRU.<BR>
  <B><CODE>DBWR revisited being-written buffer</CODE></B>: The number of times
     that the DBWR tried to save a buffer for writing and found that it was
     already in the write batch. This statistic is a measure of the amount of
     "useless" work that DBWR had to do in trying to fill the batch. This can
     occur because many sources contribute to a write batch. If the same buffer
     from different sources is considered for adding to the write batch, then
     all but the first attempt will be "useless" since the buffer is already
     marked as being written.<BR>
  <B><CODE>DBWR summed scan depth</CODE></B>: The current scan depth (number of
     buffers examined by DBWR) is added to this statistic every time the DBWR
     scans the LRU for dirty buffers. Divide by <CODE>DBWR lru scans</CODE> to
     find the average scan depth.<BR>
  <B><CODE>DBWR undo block writes</CODE></B>: The number of transaction table
     blocks written by DBWR. It is an indication of how many "hot" buffers were
     written, leading to write complete waits.<BR>
  <B><CODE>SQL*Net roundtrips to/from client</CODE></B>: Total number of Net8
     messages sent to and received from the client.<BR>
  <B><CODE>SQL*Net roundtrips to/from dblink</CODE></B>: Total number of Net8
     messages sent over and received from a database link.<BR>
  <B><CODE>background checkpoints completed</CODE></B>: The number of
     checkpoints completed by the background. This statistic is incremented
     when the background successfully advances the thread checkpoint.<BR>
  <B><CODE>background checkpoints started</CODE></B>: The number of checkpoints
     started by the background. It can be larger than the number completed if a
     new checkpoint overrides an incomplete checkpoint. This only includes
     checkpoints of the thread, not individual file checkpoints for operations
     such as offline or begin backup. This statistic does not include the
     checkpoints performed in the foreground, such as <CODE>ALTER SYSTEM
     CHECKPOINT LOCAL</CODE>.<BR>
  <B><CODE>bytes received via SQL*Net from client</CODE></B>: The total number
     of bytes received from the client over Net8.<BR>
  <B><CODE>bytes received via SQL*Net from dblink</CODE></B>: The total number
     of bytes received from a database link over Net8.<BR>
  <B><CODE>bytes sent via SQL*Net to client</CODE></B>: The total number of
     bytes sent to the client from the foreground process(es).<BR>
  <B><CODE>bytes sent via SQL*Net to dblink</CODE></B>: The total number of
     bytes sent over a database link.<BR>
  <B><CODE>calls to get snapshot scn: kcmgss</CODE></B>: The number of times a
     snap System Change Number (SCN) was allocated. The SCN is allocated at the
     start of a transaction.<BR>
  <B><CODE>change write time</CODE></B>: The elapsed time for redo write for
     changes made to CURRENT blocks in 1/10s of milliseconds.<BR>
  <B><CODE>cleanouts and rollbacks - consistent read gets</CODE></B>: The
     number of times the CR gets require both block rollbacks, and block
     cleanouts.<BR>
  <B><CODE>cleanouts only - consistent read gets</CODE></B>: The number of
     times the CR gets require only block cleanouts, no rollbacks.<BR>
  <B><CODE>cluster key scan block gets</CODE></B>: The number of blocks
     obtained in a cluster scan.<BR>
  <B><CODE>cluster key scans</CODE></B>: The number of cluster scans that were
     started.<BR>
  <B><CODE>commit cleanout failures: block lost</CODE></B>: The number of times
     a cleanout at commit was attempted and could not find the correct block
     due to forced write, replacement, or switch CURRENT.<BR>
  <B><CODE>commit cleanout failures: buffer being written</CODE></B>: The
     number of times a cleanout at commit was attempted but the buffer was
     currently being written.<BR>
  <B><CODE>commit cleanout failures: callback failure</CODE></B>: The number of
     times the cleanout callback function returns FALSE.<BR>
  <B><CODE>commit cleanout failures: cannot pin</CODE></B>: The total number of
     times a commit cleanout was performed but failed because the block could
     not be pinned.<BR>
  <B><CODE>commit cleanout failures: hot backup in progress</CODE></B>: The
     number of times cleanout at commit was attempted during hot backup. The
     image of the block needs to be logged before the buffer can be made dirty.<BR>
  <B><CODE>commit cleanout failures: write disabled</CODE></B>: The number of
     times that a cleanout at commit time was performed but the writes to the
     database had been temporarily disabled.<BR>
  <B><CODE>commit cleanouts</CODE></B>: The total number of times the cleanout
     block at commit time function was performed.<BR>
  <B><CODE>commit cleanouts successfully completed</CODE></B>: The number of
     times the cleanout block at commit time function successfully completed.<BR>
  <B><CODE>consistent changes</CODE></B>: The number of times a database block
     has applied rollback entries to perform a consistent read on the block.
     Workloads that produce a great deal of consistent changes can consume a
     great deal of resources.<BR>
  <B><CODE>consistent gets</CODE></B>: The number of times a consistent read
     was requested for a block. See also consistent changes above.<BR>
  <B><CODE>data blocks consistent reads - undo records applied</CODE></B>: The
     number of undo records applied to CR rollback data blocks.<BR>
  <B><CODE>db block changes</CODE></B>: Closely related to consistent changes,
     this statistic counts the total number of changes that were made to all
     blocks in the SGA that were part of an update or delete operation. These
     are changes that are generating redo log entries and hence will be
     permanent changes to the database if the transaction is committed. This
     statistic is a rough indication of total database work. This statistic
     indicates (possibly on a per-transaction level) the rate at which buffers
     are being dirtied.<BR>
  <B><CODE>db block gets</CODE></B>: This statistic tracks the number of blocks
     obtained in CURRENT mode.<BR>
  <B><CODE>deferred (CURRENT) block cleanout applications</CODE></B>: The
     number of times cleanout records are deferred, piggyback with changes,
     always current get.<BR>
  <B><CODE>dirty buffers inspected</CODE></B>: The number of dirty buffers
     found by the foreground while the foreground is looking for a buffer to
     reuse.<BR>
  <B><CODE>enqueue conversions</CODE></B>: The total number of enqueue converts.<BR>
  <B><CODE>enqueue deadlocks</CODE></B>: The total number of enqueue deadlocks
     between different sessions.<BR>
  <B><CODE>enqueue releases</CODE></B>: The total number of enqueue releases.<BR>
  <B><CODE>enqueue requests</CODE></B>: The total number of enqueue gets.<BR>
  <B><CODE>enqueue timeouts</CODE></B>: The total number of enqueue operations
     (get and convert) that timed out before they could complete.<BR>
  <B><CODE>enqueue waits</CODE></B>: The total number of waits that happened
     during an enqueue convert or get because the enqueue could not be granted
     right away.<BR>
  <B><CODE>execute count</CODE></B>: The total number of calls (user and
      recursive) that execute SQL statements.<BR>
  <B><CODE>free buffer inspected</CODE></B>: The number of buffers skipped over
     from the end of an LRU queue in order to find a reusable buffer. The
     difference between this statistic and <code>dirty buffers inspected</code>
     is the number of buffers that could not be used because they were busy,
     needed to be written after rapid aging out, or they have a user, a waiter,
     or are being read/written. For more information, see <code>dirty buffers
     inspected</code>.<BR>
  <B><CODE>free buffer requested</CODE></B>: The count of the number of times
     a reusable buffer or a free buffer was requested to create or load a block.<BR>
  <B><CODE>immediate (CR) block cleanout applications</CODE></B>: The number of
     times cleanout records are applied immediately during CR gets.<BR>
  <B><CODE>immediate (CURRENT) block cleanout applications</CODE></B>: The
     number of times cleanout records are applied immediately during current
     gets.<BR>
  <B><CODE>logons cumulative</CODE></B>: The total number of logons since the
     instance started.<BR>
  <B><CODE>logons current</CODE></B>: The total number of current logons.<BR>
  <B><CODE>no work - consistent read gets</CODE></B>: The number of times CR
     gets require no block cleanouts nor rollbacks.<BR>
  <B><CODE>opened cursors cumulative</CODE></B>: The total number of opened
     cursors since the instance has started.<BR>
  <B><CODE>opened cursors current</CODE></B>: The total number of current open
     cursors.<BR>
  <B><CODE>parse count (hard)</CODE></B>: The total number of parse calls (real
     parses). A hard parse means allocating a workheap and other memory
     structures, and then building a parse tree. A hard parse is a very
     expensive operation in terms of memory use.<BR>
  <B><CODE>parse count (total)</CODE></B>: Total number of parse calls (hard
     and soft). A soft parse is a check to make sure that the permissions on
     the underlying object have not changed.<BR>
  <B><CODE>parse time cpu</CODE></B>: The total CPU time used for parsing (hard
     and soft) in 10s of milliseconds.<BR>
  <B><CODE>parse time elapsed</CODE></B>: The total elapsed time for parsing in
     10s of milliseconds. By subtracting parse time CPU from this statistic,
     the total waiting time for parse resources is determined. For more
     information, see <code>parse time cpu</code> above.<BR>
  <B><CODE>physical reads</CODE></B>: The total number of data blocks read from
     disk. This equals the number of <code>physical reads direct</code> plus
     all reads into buffer cache.<BR>
  <B><CODE>physical writes</CODE></B>: The total number of data blocks written
     to disk. This equals the number of <code>physical writes direct</code>
     plus all writes from buffer cache.<BR>
  <B><CODE>recursive calls</CODE></B>: Oracle maintains tables used for
     internal processing. When Oracle needs to make a change to these tables,
     it internally generates a SQL statement. These internal SQL statements
     generate recursive calls.<BR>
  <B><CODE>recursive cpu usage</CODE></B>: The total CPU time used by non-user
     calls (<code>recursive calls</code>). Subtract this value from <code>CPU
     used by this session</code> to determine how much CPU time was used by the
     user calls.<BR>
  <B><CODE>redo entries</CODE></B>: This statistic increments each time redo
     entries are copied into the redo log buffer.<BR>
  <B><CODE>redo log space requests</CODE></B>: The active log file is full and
     Oracle is waiting for disk space to be allocated for the redo log entries.
     Space is created by performing a log switch. Small log files in relation
     to the size of the SGA or the commit rate of the workload can cause
     problems. When the log switch occurs, Oracle must ensure that all
     committed dirty buffers are written to disk before switching to a new log
     file. If you have a large SGA full of dirty buffers and small redo log
     files, a log switch must wait for DBWR to write dirty buffers to disk
     before continuing. Also, examine the <code>log file space</code> and
     <code>log file space switch wait</code> events in <code>V$SESSION_WAIT</code>.<BR>
  <B><CODE>redo log space wait time</CODE></B>: The total elapsed time of
     waiting for redo log space request in 10s of milliseconds.<BR>
  <B><CODE>redo ordering marks</CODE></B>: The number of times that an SCN had
     to be allocated to force a redo record to have a higher SCN than a record
     generated in another thread using the same block.<BR>
  <B><CODE>redo size</CODE></B>: The total amount of redo generated in bytes.<BR>
  <B><CODE>redo synch time</CODE></B>: The elapsed time of all redo sync write
     calls in 10s of milliseconds.<BR>
  <B><CODE>redo synch writes</CODE></B>: Usually, redo that is generated and
     copied into the log buffer need not be flushed out to disk immediately.
     The log buffer is a circular buffer that LGWR periodically flushes.
     <code>Redo sync writes</code> increments when changes being applied must
     be written out to disk due to a commit.<BR>
  <B><CODE>redo wastage</CODE></B>: Number of bytes wasted because redo blocks
     needed to be written before they are completely full. Early writing may be
     needed to commit transactions, to be able to write a database buffer or to
     switch logs.<BR>
  <B><CODE>redo write time</CODE></B>: The total elapsed time of the write from
     the redo log buffer to the current redo log file in 10s of milliseconds.<BR>
  <B><CODE>redo writer latching time</CODE></B>: The elapsed time need by LWGR
     to obtain and release each copy latch in 10s of milliseconds. This is only
     used if the initialization parameter <code>LOG_SIMULTANEOUS_COPIES</code>
     &gt; 0.<BR>
  <B><CODE>redo writes</CODE></B>: Count of the total number of writes by LGWR
     to the redo log files.<BR>
  <B><CODE>rollback changes - undo records applied</CODE></B>: <BR>
  <B><CODE>rollbacks only - consistent read gets</CODE></B>: <BR>
  <B><CODE>session connect time</CODE></B>: The connect time for the session in
     1/100 seconds. This is the wall clock time of when the logon to this
     session occurred.<BR>
  <B><CODE>session logical reads</CODE></B>: This statistic is basically
     <code>db block gets</code> + <code>consistent gets</code>.<BR>
  <B><CODE>session pga memory</CODE></B>: This statistic shows the current PGA
     size for a session. It is useful only in session statistics, and thus has
     no meaning here.<BR>
  <B><CODE>session pga memory max</CODE></B>: This statistic shows the peak PGA
     size for a session. It is useful only in session statistics, and thus has
     no meaning here.<BR>
  <B><CODE>session uga memory</CODE></B>: This statistic shows the current UGA
     size for a session. It is useful only in session statistics, and thus has
     no meaning here.<BR>
  <B><CODE>session uga memory max</CODE></B>: This statistic shows the peak UGA
     size for a session. It is useful only in session statistics, and thus has
     no meaning here.<BR>
  <B><CODE>sorts (disk)</CODE></B>: If the number of disk writes is non-zero
     for a given sort operation, then this statistic is incremented. Sorts that
     require I/O to disk are quite resource intensive. Try increasing the size
     of the initialization parameter <code>SORT_AREA_SIZE</code> when the ratio
     for "In-memory Sorts" in the "Instance Efficiency Percentage" segment of
     the report is low.<BR>
  <B><CODE>sorts (memory)</CODE></B>: If the number of disk writes is zero,
     then the sort was performed completely in memory and this statistic is
     incremented. This is further indication of sorting activity in the
     application workload. You cannot do much better than memory sorts, except
     maybe no sorts at all. Sorting is usually caused by selection criteria
     specifications within table join SQL operations.<BR>
  <B><CODE>sorts (rows)</CODE></B>: The total number of rows sorted.<BR>
  <B><CODE>summed dirty queue length</CODE></B>: The sum of the dirty LRU queue
     length after every write request. Divide by <code>writes requests</code>
     to get the average queue length after write completion.<BR>
  <B><CODE>table fetch by rowid</CODE></B>: When rows are fetched using a ROWID
     (usually recovered from an index), each row returned increments this
     counter. This statistic is an indication of row fetch operations being
     performed with the aid of an index. Because doing table scans usually
     indicates either non-optimal queries or tables without indexes, this
     statistic should increase as the above issues have been addressed in the
     application.<BR>
  <B><CODE>table fetch continued row</CODE></B>: When a row that spans more
     than one block is encountered during a fetch, this statistic is
     incremented. Retrieving rows that span more than one block increases the
     logical I/O by a factor that corresponds to the number of blocks than need
     to be accessed. Exporting and re-importing may eliminate this problem.
     Taking a closer look at the <code>STORAGE</code> parameters
     <code>PCT_FREE</code> and <code>PCT_USED</code>. This problem cannot be
     fixed if rows are larger than database blocks (for example, if the
     <code>LONG</code> datatype is used and the rows are extremely large).<BR>
  <B><CODE>table scan blocks gotten</CODE></B>: During scanning operations,
     each row is retrieved sequentially by Oracle. Each block encountered
     during the scan increments this statistic. This statistic informs you of
     the number of database blocks that you had to get from the buffer cache
     for the purpose of scanning. Compare the value of this parameter to the
     value of <code>consistent gets</code> to get a feeling for how much of the
     consistent read activity can be attributed to scanning.<BR>
  <B><CODE>table scan rows gotten</CODE></B>: This statistic is collected
     during a scan operation, but instead of counting the number of database
     blocks, it counts the rows being processed.<BR>
  <B><CODE>table scan (cache partitions)</CODE></B>: Count of range scans on
     tables that have the <code>CACHE</code> option enabled.<BR>
  <B><CODE>table scan (direct read)</CODE></B>: Count of table scans performed
     with direct read (bypassing the buffer cache).<BR>
  <B><CODE>table scans (long tables)</CODE></B>: Long (or conversely short)
     tables can be defined as tables that do not meet the short table criteria
     as described in <code>table scans (short tables)</code> below.<BR>
  <B><CODE>table scan (rowid ranges)</CODE></B>: Count of table scans with
     specified <code>ROWID</code> endpoints. This is performed for Parallel
     Query.<BR>
  <B><CODE>table scans (short tables)</CODE></B>: Long (or conversely short)
     tables can be defined by optimizer hints coming down into the row source
     access layer of Oracle. The table must have the <code>CACHE</code> option
     set.<BR>
  <B><CODE>transaction rollbacks</CODE></B>: The number of transactions being
     successfully rolled back.<BR>
  <B><CODE>transaction tables consistent read rollbacks</CODE></B>: The number
     of times transaction tables are CR rolled back.<BR>
  <B><CODE>transaction tables consistent reads - undo records applied</CODE></B>:
     The number of undo records applied to CR rollback transaction tables.<BR>
  <B><CODE>user calls</CODE></B>: Oracle allocates resources (Call State
     Objects) to keep track of relevant user call data structures every time
     you log in, parse or execute. When determining activity, the ratio of user
     calls to RPI calls, indicates how much internal work gets generated as a
     result of the type of requests the user is sending to Oracle.<BR>
  <B><CODE>user commits</CODE></B>: When a user commits a transaction, the redo
     generated that reflects the changes made to database blocks must be
     written to disk. Commits often represent the closest thing to a user
     transaction rate.<BR>
  <B><CODE>user rollbacks</CODE></B>: This statistic stores the number of times
     users manually issue the <code>ROLLBACK</code> statement or an error
     occurs during users' transactions.<BR>
  <B><CODE>write requests</CODE></B>: This statistic stores the number of times
     DBWR takes a batch of dirty buffers and writes them to disk.<BR>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2004 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
