<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Latch Free</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are <CODE>latch free</CODE> waits?</H3>
 <P>A latch is a low-level internal lock used by Oracle to protect memory
  structures. The <CODE>latch free</CODE> wait event occurs whenever one Oracle
  process is requesting a "willing to wait" latch from another process. The
  event only occurs if the spin_count has been exhausted, and the waiting
  process goes to sleep.</P>
 <P>Latch free waits can occur for a variety of reasons including library cache
  issues, OS process intervention (processes being put to sleep by the OS, etc.),
  and so on. One possible cause can also be an oversized shared pool (yes, a
  bigger large pool not always results in better performance!): Increasing the
  shared pool allows for a larger number of versions of SQL; this will
  increase the amount of CPU and latching required for Oracle in order to
  determine whether a "new" statement is present in the library cache or not.</P>
 <P>If you have many <CODE>latch free</CODE> waits, you need to further
  investigate what latches are affected. A good point to start with is Oracle
  StatsPack which lists them all up in a reasonable order (and you may use my
  OSPRep Report generator to list them all up ;)</P>
 <H3>What actions can be taken?</H3>
 <P>This event should only be a concern if latch waits are a significant
  portion of the wait time on the system as a whole, or for individual users
  experiencing problems.</P>
 <UL>
   <LI>To help determine the cause of this wait event, identify the latch(es)
       contended for. There are many types of latches used for different
       purposes. For example, the shared pool latch protects certain actions in
       the shared pool, and the cache buffers LRU chain protects certain
       actions in the buffer cache.</LI>
   <LI>Examine the resource usage for related resources. For example, if the
       library cache latch is heavily contended for, then examine the hard and
       soft parse.</LI>
   <LI>Examine the SQL statements for the sessions experiencing latch
       contention to see if there is any commonality.</LI>
 </UL>
 <P>In the <CODE>V$SESSION_WAIT</CODE> view, you find the address of the latch
  in column P1, the latch number in P2 and the number of times process has
  already slept in waiting for the latch in P3:
  <TABLE ALIGN="center"><TR><TD>
  <DIV CLASS="code" STYLE="width:23em">
  SELECT n.name, SUM(w.p3) Sleeps<BR>
  &nbsp;&nbsp;FROM v$session_wait w, v$latchname n<BR>
  &nbsp;WHERE w.event = 'latch free'<BR>
  &nbsp;&nbsp;&nbsp;AND w.p2    = n.latch#<BR>
  &nbsp;GROUP BY n.name;</DIV>
  </TD></TR></TABLE>
 <P>Following table lists up some latches with additional information:</P>
 <TABLE WIDTH="95%" BORDER="1" ALIGN="center">
  <TR><TH CLASS="th_sub2">Latch</TH><TH CLASS="th_sub2">SGA Area</TH>
      <TH CLASS="th_sub2">Possible Causes</TH><TH CLASS="th_sub2">Look For:</TH></TR>
  <TR><TD>shared pool, library cache</TD><TD>Shared Pool</TD>
      <TD><UL><LI>Lack of statement reuse</LI>
              <LI>Statements not using bind variables</LI>
	      <LI>Insufficient size of application cursor cache</LI>
	      <LI>Cursors closed explicitly after each execution</LI>
	      <LI>Frequent logon/logoffs</LI>
	      <LI>Underlying object structure being modified (for example truncate)</LI>
	      <LI>Shared Pool too small</LI></UL></TD>
      <TD>Sessions (in <CODE>V$SESSTAT</CODE>) with high:<UL>
          <LI>parse time CPU</LI><LI>parse time elapsed</LI>
	  <LI>ratio of parse count (hard) / execute count</LI>
	  <LI>ratio of parse count (total) / execute count</LI></UL>
	  Cursors (in <CODE>V$SQLAREA / V$SQL</CODE>) with:<UL>
	  <LI>high ratio of parse calls / executions</LI>
	  <LI>executions = 1 differing only in literals in the <CODE>WHERE</CODE>
	      clause (that is, no bind variables used)</LI>
	  <LI>high <CODE>RELOADS</CODE></LI><LI>high <CODE>INVALIDATIONS</CODE></LI>
	  <LI>large (&gt; 1 MB) <CODE>SHARABLE_MEM</CODE></LI></UL></TD></TR>
  <TR><TD>cache buffers lru chain</TD><TD>Buffer Cache LRU lists</TD>
      <TD><UL><LI>Excessive buffer cache throughput. For example, many
                  cache-based sorts, inefficient SQL that accesses incorrect
		  indexes iteratively (large index range scans), or many full
		  table scans</LI>
	      <LI>DBWR not keeping up with the dirty workload; hence, foreground
	          process spends longer holding the latch looking for a free buffer</LI>
	      <LI>Cache may be too small</LI></UL></TD>
      <TD>Statements with very high LIO/PIO using unselective indexes</TD></TR>
  <TR><TD>cache buffer chains</TD><TD>Buffer Cache Buffers</TD>
      <TD>Repeated access to a block (or small number of blocks), known as
          "hot block"</TD>
      <TD><UL><LI>Sequence number generation code that updates a row in a table
                  to generate the number, rather than using a sequence number
		  generator</LI>
              <LI>Identify the segment the hot block belongs to</LI></UL></TD></TR>
 </TABLE>
 <H3>Shared Pool and Library Cache Latch Contention</H3>
 <P>A main cause of shared pool or library cache latch contention is parsing.
  There are a number of techniques that can be used to identify unnecessary
  parsing and a number of types of unnecessary parsing:</P>
 <P><B>Unshared SQL</B><BR>
  This method identifies similar SQL statements that could be shared if
  literals were replaced with bind variables. The idea is to either:<UL>
  <LI>Manually inspect SQL statements that have only one execution to see
      whether they are similar:
      <TABLE ALIGN="center"><TR><TD>
      <DIV CLASS="code" STYLE="width:13em">
      SELECT sqltext<BR>
      &nbsp;&nbsp;FROM v$sqlarea<BR>
      &nbsp;WHERE executions = 1<BR>
      &nbsp;ORDER BY sql_text;</DIV></TD></TR></TABLE></LI>
  <LI>Or, automate this process by grouping together what may be similar
      statements. Do this by estimating the number of bytes of a SQL statement
      which will likely be the same, and group the SQL statements by that many
      bytes. For example, the example below groups together statements that
      differ only after the first 60 bytes.
      <TABLE ALIGN="center"><TR><TD>
      <DIV CLASS="code" STYLE="width:23em">
      SELECT SUBSTR(sql_text,1, 60), COUNT(*)<BR>
      &nbsp;&nbsp;FROM V$SQLAREA<BR>
      &nbsp;WHERE executions = 1<BR>
      &nbsp;GROUP BY SUBSTR(sql_text, 1, 60)<BR>
      HAVING COUNT(*) > 1;</DIV>
      </TD></TR></TABLE></LI></UL></P>
 <P><B>Reparsed Sharable SQL</B><BR>
  Check the V$SQLAREA view. Enter the following query:
  <TABLE ALIGN="center"><TR><TD>
  <DIV CLASS="code" STYLE="width:25em">
  SELECT sql_text, parse_calls, executions<BR>
  &nbsp;&nbsp;FROM v$sqlarea<BR>
  &nbsp;ORDER BY parse_calls;</DIV>
  </TD></TR></TABLE>
  When the <CODE>PARSE_CALLS</CODE> value is close to the <CODE>EXECUTIONS<CODE>
  value for a given statement, you might be continually reparsing that
  statement. Tune the statements with the higher numbers of parse calls.</P>
 <P><B>By Session</B><BR>
  Identify unnecessary parse calls by identifying the session in which they
  occur. It might be that particular batch programs or certain types of
  applications do most of the reparsing. To do this, run the following query:
  <TABLE ALIGN="center"><TR><TD>
  <DIV CLASS="code" STYLE="width:32em">
  column sid format 99999<BR>
  column name format a20<BR>
  SELECT ss.sid, sn.name, ss.value<BR>
  &nbsp;&nbsp;FROM V$SESSTAT  ss, V$STATNAME sn<BR>
  &nbsp;WHERE name IN ('parse count (hard)','execute count')<BR>
  &nbsp;&nbsp;&nbsp;AND ss.statistic# = sn.statistic#<BR>
  &nbsp;&nbsp;&nbsp;AND ss.value > 0<BR>
  &nbsp;ORDER BY value, sid;</DIV>
  </TD></TR></TABLE>
  The result is a list of all sessions and the amount of reparsing they do. For
  each system identifier (SID), go to V$SESSION to find the name of the program
  that causes the reparsing.</P>
 <H3>Cache buffer LRU chain</H3>
 <P>The cache buffer lru chain latches protect the lists of buffers in the
  cache. When adding, moving, or removing a buffer from a list, a latch must be
  obtained.</P>
 <P>For symmetric multiprocessor (SMP) systems, Oracle automatically sets the
  number of LRU latches to a value equal to one half the number of CPUs on the
  system. For non-SMP systems, one LRU latch is sufficient.</P>
 <P>Contention for the LRU latch can impede performance on SMP machines with a
  large number of CPUs. LRU latch contention is detected by querying
  <CODE>V$LATCH</CODE>, <CODE>V$SESSION_EVENT</CODE>, and <CODE>V$SYSTEM_EVENT</CODE>.
  To avoid contention, consider bypassing the buffer cache or redesigning the
  application.
 <H3>Cache buffer chains</H3>
 <P>The <CODE>cache buffers chains</CODE> latches are used to protect a buffer
  list in the buffer cache. These latches are used when searching for, adding,
  or removing a buffer from the buffer cache. Contention on this latch usually
  means that there is a block that is greatly contended for (that is, 'hot)'
  block.</P>
 <P>To identify the heavily accessed buffer chain, and hence the contended for
  block, look at latch statistics for the cache buffers chains latches using
  the view <CODE>V$LATCH_CHILDREN</CODE>. If there is a specific cache buffers
  chains child latch that has many more GETS, MISSES, and SLEEPS when compared
  with the other child latches, then this is the contended for child latch.</P>
 <P>This latch has a memory address, identified by the ADDR column. Use the
  value in the ADDR column joined with the <CODE>V$BH</CODE> view to identify
  the blocks protected by this latch. For example, given the address
  (<CODE>V$LATCH_CHILDREN.ADDR</CODE>) of a heavily contended latch, this
  queries the file and block numbers:
  <TABLE ALIGN="center"><TR><TD>
  <DIV CLASS="code" STYLE="width:22em">
  SELECT file#, dbablk, class, state<BR>
  &nbsp;&nbsp;FROM X$BH<BR>
  &nbsp;WHERE HLADDR='address of latch';</DIV>
  </TD></TR></TABLE>
  There are many blocks protected by each latch. One of these buffers will
  likely be the hot block. Perform this query a number of times, and identify
  the block that consistently appears in the output, using the combination of
  file number (<CODE>file#</CODE>) and block number (<CODE>dbablk</CODE>). This
  is most likely the hot block. After the hot block has been identified, query
  <CODE>DBA_EXTENTS</CODE> using the file number and block number, to identify
  the segment.</P>
</TD></TR></TABLE>

</BODY></HTML>
