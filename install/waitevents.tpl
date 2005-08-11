<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Selected Wait Events</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Selected Wait Events</H3>
 <P>The following table describes some of the more important wait events and gives some
    details on what they mean:</P>
  <TABLE ALIGN="center" BORDER="1" WIDTH="95%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub" STYLE="width:10em">Wait Event</TH><TH CLASS="th_sub">Description</TH>
       <TH CLASS="th_sub">Wait Time</TH></TR>
   <TR><TD CLASS="td_name">async disk IO</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This is a general async IO completion wait
           used in a number of places in the code. The wait means that the Oracle process is
           waiting for either:<UL>
           <LI>completion of 1 or more actual async IO's</LI>
           <LI>response/s from IO Slave processes</LI></UL>
           In 9.0 the wait is used by DBW, LGWR, CKPT, ARCH, and for backups etc.. so does not
           give a useful indication of what the waits are related to. In 9.2 a number of the
           wait scenarios have had their async IO waits reclassified under more meaningful wait
           events. The main situations using "async disk IO" in 9.2 are:<UL>
           <LI>Asynchronous log reads</LI>
           <LI>Trace write waits</LI>
           <LI>LGWR waits for pending i/o's during database shutdown due to standby database failure</LI>
           <LI>Archive log write waits when detaching rfs process.</LI></UL></TD>
       <TD CLASS="inner">Waits for the requested number of IO completions, or until posted.</TD></TR>
   <TR><TD CLASS="td_name">control file parallel write</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This event occurs while the session is writing
           physical blocks to all control files. This happens when:<UL>
           <LI>The session starts a control file transaction (to make sure that the control files
               are up to date in case the session crashes before committing the control file
               transaction)</LI>
           <LI>The session commits a transaction to a control file</LI>
           <LI>Changing a generic entry in the control file, the new value is being written to all
           control files</LI></UL></TD>
       <TD CLASS="inner">The wait time is the time it takes to finish all writes to all control files</TD></TR>
   <TR><TD CLASS="td_name">control file sequential read</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Reading from the control file. This happens in
           many cases. For example, while:<UL>
           <LI>Making a backup of the controlfiles</LI>
           <LI>Sharing information (between instances) from the controlfile</LI>
           <LI>Reading other blocks from the controlfiles</LI>
           <LI>Reading the header block</LI></UL></TD>
       <TD CLASS="inner">The wait time is the elapsed time of the read</TD></TR>
   <TR><TD CLASS="td_name">db file parallel write</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This event occurs in the DBWR. It indicates
           that the DBWR is performing a parallel write to files and blocks. The parameter
           requests indicates the real number of I/Os that are being performed. When the last I/O
           has gone to disk, the wait ends. This wait should only occur in database writer
           processes. The blocker is the Operating System IO subsystem.<BR>
           If this is a significant portion of the total wait time it is not necessarily having
           a large impact on on user sessions. If user sessions show a large wait time on "write
           complete waits" and / or "free buffer waits" then this is impacting user sessions. A
           less obvious impact can be on the IO subsystem in that the writes may be impacting
           read times of sessions reading from the same disks.<BR><BR>
           DBWR throughput is very platform and version specific so only general observations
           can be made here. The following items may influence the rate at which DBWR can clear
           blocks from the cache:<UL>
           <LI>Physical disk attributes (stripe size, speed, layout etc..)</LI>
           <LI>Raw devices versus File System Files</LI>
           <LI>Spreading written data across more disks/files</LI>
           <LI>Using Asynchronous writes where available</LI>
           <LI>Using multiple database writers where asynch. IO is not available.
               Use the <CODE>DBWR_IO_SLAVES</CODE> parameter for this.</LI>
           <LI>In Oracle8, using multiple DB Writer gatherer processes
               (<CODE>DB_WRITER_PROCESSES</CODE>).</LI>
           <LI>Setting <CODE>_DB_BLOCK_WRITE_BATCH</CODE> to a large number. This parameter is
               obsoleted in 8.1.</LI>
           <LI>Using the "Multiple buffer pools" feature (see help on
               <A HREF="poolsize.html">pool sizes</A> for more details on this).</LI></UL>
           Note that there many port specific issues which affect the optimal setup for DBWR on a
           given platform. These range from choosing a <CODE>DB_BLOCK_SIZE</CODE> which is a
           multiple of the page size used by the operating system for IO operations to configuring
           Asynchronous IO correctly.</TD>
       <TD CLASS="inner">Wait until all of the I/Os are completed</TD></TR>
   <TR><TD CLASS="td_name">db file scattered read</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This wait happens when a session is waiting
           for a multiblock IO to complete. This typically occurs during full table scans or
           index fast full scans. Oracle reads up to <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE>
           consecutive blocks at a time and scatters them into buffers in the buffer cache.<BR>
           See also "db file sequential read" for how to minimize this wait. Additionally to the
           items listed there, the <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> should generally
           be made as large as possible. The value is usually capped by Oracle and so it cannot
           be set too high. The 'capped' value differs between platforms and versions and
           usually depends on the settings of <CODE>DB_BLOCK_SIZE</CODE>.</TD>
       <TD CLASS="inner">The wait time is the actual time it takes to do all of the I/Os
           (The wait blocks until all blocks in the IO request have been read).</TD></TR>
   <TR><TD CLASS="td_name">db file sequential read</TD>
       <TD CLASS="inner" STYLE="text-align:justify">The session waits while a sequential read
           from the database is performed. This event is also used for rebuilding the control
           file, dumping datafile headers, and getting the database file headers.
           This call differs from "db file scattered read" in that a sequential read reads data
           into contiguous memory (whilst a scattered read reads multiple blocks and scatters
           them into different buffers in the SGA).<BR>
           If this value is significantly high, see the "Tablespace IO" and "File IO" sections of
           the report to get information on which tablespaces / files are servicing the most IO
           requests, and to get an indication of the speed of the IO subsystem. Furthermore it can
           be helpful in this case to determine which segment/s Oracle is performing the reads
           against. This you can find out in the segment stats section of the report.<BR>
           How to minimize this wait event:<UL>
           <LI>tune the affecting SQL statements (if possible)</LI>
           <LI>A larger buffer cache can help - test this by actually increasing
               <CODE>DB_BLOCK_BUFFERS</CODE> (Oracle 8i) / <CODE>DB_CACHE_SIZE</CODE> (9i+)
               parameter.</LI>
           <LI>See if partitioning can be used to reduce the amount of data you need to look at.</LI>
           <LI>It can help to place files which incur frequent index scans on disks which have
               are buffered by an O/S file system cache. Often this will allow some of Oracles read
               requests to be satisfied from the OS cache rather than from a real disk IO.</LI></UL></TD>
       <TD CLASS="inner">The wait time is the actual time it takes to do the I/O.
           The wait blocks until the IO request completes.</TD></TR>
   <TR><TD CLASS="td_name">direct path read</TD>
       <TD CLASS="inner" STYLE="text-align:justify" ROWSPAN="2">During Direct Path operations the
           data is asynchronously read from/written to the database files. At some stage the session
           needs to make sure that all outstanding asynchronous I/O have been completed to disk.
           This can also happen if during a direct read no more slots are available to store
           outstanding load requests (a load request could consist of multiple I/Os).<BR><BR>
           <B><I>Direct path reads</I></B> are generally used by Oracle when reading directly into
           PGA memory (as opposed to into the buffer cache). If asynchronous IO is supported (and
           in use) then Oracle can submit IO requests and continue processing. It can then pick up
           the results of the IO request later and will wait on "direct path read" until the
           required IO completes.<BR>
           <B><I>Direct path writes</I></B> allow a session to queue an IO write request and continue
           processing whilst the OS handles the IO. If the session needs to know if an outstanding
           write is complete then it waits on this waitevent. This can happen because the session
           is out of free slots and just needs an empty buffer (it waits on the oldest IO) or
           because it needs to ensure all writes are flushed.<BR><BR>
           If asynchronous IO is not being used then the IO requests block until completed but these
           do not show as waits at the time the IO is issued. The session returns later to pick up the
           completed IO data but can then show a wait on "direct path read" / "direct path write"
           even though this wait will return immediately.<BR>
           Hence this wait event is very misleading as:<UL>
           <LI>The total number of waits does not reflect the number of IO requests</LI>
           <LI>The total time spent in "direct path read" / "direct path write" does not always
               reflect the true wait time.</LI></UL>
           This style of read request is typically used for:<UL>
           <LI>direct path read:<UL>
             <LI>Sort IO (when a sort does not fit in memory)</LI>
             <LI>Parallel Query slaves</LI>
             <LI>Readahead (where a process may issue an IO request for a block it expects to need in
                 the near future)</LI></UL></LI>
           <LI>direct path write:<UL>
             <LI>Direct load operations (eg: Create Table as Select (CTAS) may use this)</LI>
             <LI>Parallel DML operations</LI>
             <LI>Sort IO (when a sort does not fit in memory)</LI>
             <LI>Writes to uncached "LOB" segments (later releases wait on "direct path write (lob)")</LI></UL></LI></UL>
           How you may reduce these waits:<UL>
           <LI>If the file indicates a temporary tablespace check for unexpected disk sort operations.</LI>
           <LI>Ensure <CODE>DISK_ASYNCH_IO</CODE> is TRUE . This is unlikely to reduce wait times
               from the wait event timings but may reduce sessions elapsed times (as synchronous
               direct IO is not accounted for in wait event timings).</LI>
           <LI>Ensure the OS asynchronous IO is configured correctly.</LI>
           <LI>Check for IO heavy sessions / SQL and see if the amount of IO can be reduced.</LI>
           <LI>Ensure no disks are IO bound.</LI></TD>
       <TD CLASS="inner" ROWSPAN="2">10 seconds. The session will be posted by the completing
           asynchronous I/O. It will never wait the entire 10 seconds. The session waits in a tight
           loop until all outstanding I/Os have completed.</TD></TR>
   <TR><TD CLASS="td_name">direct path write</TD></TR>
   <TR><TD CLASS="td_name">log file parallel write</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Writing redo records to the redo log files
           from the log buffer. The waits occur in log writer (LGWR) as part of normal activity
           of copying records from the redo log buffer to the current online log. As this wait is
           not used by normal Oracle shadow processes the "systemwide" figure should not be
           included directly in comparisons. If waits for "log file parallel write" are
           significant then this will show up as other user wait events (such as long "log file
           sync" wait times).<BR><BR>
           You might want to reduce "log file parallel write" wait times in order to reduce user
           waits which depend on LGWR:<UL>
           <LI>Ensure tablespaces are NOT left in HOT BACKUP mode longer than needed. Tablespaces
               in HOT BACKUP mode cause more redo to be generated for each change which can vastly
               increase the rate of redo generarion.</LI>
           <LI>Redo log members should ideally be on high speed disks, eg: RAID5 is not a good
               candidate for redo log members.</LI>
           <LI>Redo log members should be on disks with little/no IO activity from other sources.
               (including low activity from other sources against the same disk controller)</LI>
           <LI>RAW devices can be faster file system files.</LI>
           <LI><CODE>NOLOGGING</CODE> / <CODE>UNRECOVERABLE</CODE> operations may be possible for
               certain operations to reduce the overall rate of redo generation</LI></UL></TD>
       <TD CLASS="inner">Time it takes for the I/Os to complete. Even though redo records are
           written in parallel, the parallel write is not complete until the last I/O is on disk.</TD></TR>
   <TR><TD CLASS="td_name">log file sync</TD>
       <TD CLASS="inner" STYLE="text-align:justify">When a user session commits, the session's
           redo information needs to be flushed to the redo logfile. The user session will post
           the LGWR to write the log buffer to the redo log file. When the LGWR has finished
           writing, it will post the user session. The user session waits on this wait event
           while waiting for LGWR to post it back to confirm all redo changes are safely on disk.<BR>
           "log file sync" lso applies to <CODE>ROLLBACK</CODE> in that once the rollback is
           complete the end of the rollback operation requires all changes to complete the
           rollback to be flushed to the redo log.<BR><BR>
           There are 3 main things you can do to help reduce waits on "log file sync":<UL>
           <LI>Tune LGWR to get good throughput to disk, eg: Do not put redo logs on RAID 5.</LI>
           <LI>If there are lots of short duration transactions see if it is possible to BATCH
               transactions together so there are fewer distinct <CODE>COMMIT</CODE> operations.
               Each commit has to have it confirmed that the relevant REDO is on disk. Although
               commits can be "piggybacked" by Oracle reducing the overall number of commits by
               batching transactions can have a very beneficial effect.</LI>
           <LI>See if any activity can safely be done with <CODE>NOLOGGING</CODE> /
               <CODE>UNRECOVERABLE</CODE> options.</LI></UL></TD>
       <TD CLASS="inner">The wait time includes the writing of the log buffer and the post.
           The waiter times out and increments the sequence number every second while waiting.</TD></TR>
   <TR><TD CLASS="td_name"></TD>
       <TD CLASS="inner" STYLE="text-align:justify"></TD>
       <TD CLASS="inner"></TD></TR>
  </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
