<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Latches</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What is a "Latch"?</H3>
 <P>Latches are a kind of very short "Locks" to protect data structures in the
  SGA. Other than enqueues, for latches there exists no FiFo wait queue - so
  waiting processes either "spin" (in multi-processor environments only) or
  "sleep", and retry their request later. As a side-effect, there's no special
  order in processing of requests: in fact, the first process encountering a
  special latch wait could be the last one getting the latch. Connected with
  each latch is its level - to avoid deadlocks, a process already holding a
  latch cannot obtain another latch of the same or subordinate level.</P>
 <H3>What is this table about?</H3>
 <P><I>Pct Get Miss</I>es and <I>Pct NoWait Miss</I>es should be low. <I>Pct
  Get Miss</I> is the percentage of time a latch was requested (in a
  willing-to-wait mode) and not obtained immediately. For latches requested
  in No-Wait mode, <I>Pct NoWait Miss</I>es is a percentage based on the
  number of times a latch was requested in NoWait mode, and the latch request
  was not successful.</P>
 <P>For willing-to-wait latch gets, also examine the <I>Avg Slps/Miss</I>
  statistic which shows the average number of times a server process had to
  sleep before being able to acquire the latch. This statistic should be low.</P>
 <P>Look at the raw sleep data in the <I>Latch Sleep Breakdown</I> section, and
  identify latches which are obtained by spinning or by sleeping, with sleeping
  being the most expensive method of getting the latch.</P>
 <P>The <I>Latch Miss Sources</I> report is primarily useful to Oracle Support
  staff. The data here is used to identify the code which was executing at the
  time the latch was not obtained (i.e. "missed").</P>
 <P>Three of the most common latches waited for are the shared pool, library cache
  and cache buffers chains latches. Latch contention is not usually a problem in
  itself, but is symptomatic of other issues. For example, contention on the
  shared pool and library cache latches can often be symptomatic of unnecessary
  parsing, or of very high rates of logon/logoffs initiated by middle-tier
  software. Unnecessary parsing can be can be avoided by writing sharable SQL
  which uses bind variables. Middle tier software can be designed to connect to
  the database once and maintain the connections, rather than connect/disconnect
  from the instance for each database call.</P>
 <P>Latch contention for these latches can also be caused by loading large
  PL/SQL packages into the shared pool; to avoid this activity, look at pinning
  these packages to avoid them aging out.</P>
 <P>Contention on a cache buffers chains latch can sometimes be caused by very
  heavy access to a single block - this would require identifying the hot
  block, and then why the block is being contended for.</P>

 <H3>Potential Fixes for indicated Latch problems</H3>
  <TABLE ALIGN="center" WIDTH="90%" BORDER="1" WIDTH="95%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">Latch</TH><TH CLASS="th_sub">Potential Fix</TH></TR>
   <TR><TD>library cache and shared pool latches</TD>
       <TD>adjusting the <CODE>shared_pool_size</CODE> and use of bind
           variables / set <CODE>cursor_sharing</CODE> parameter (see e.g.
	   <A HREF="libcache.html">Library Cache</A> for details) in your
           <CODE>init.ora</CODE></TD></TR>
   <TR><TD>redo allocation latches</TD>
       <TD>minimize redo generation and avoid unnecessary commits</TD></TR>
   <TR><TD>redo copy latches</TD>
       <TD>increase the <CODE>log_simultaneous_copies</CODE></TD></TR>
   <TR><TD>row cache objects latches</TD>
       <TD>increase the <CODE>shared_pool_size</CODE></TD></TR>
   <TR><TD>cache buffer chain latches</TD>
       <TD>adjust _db_block_hash_buckets</TD></TR>
   <TR><TD>cache buffer latches</TD>
       <TD>use _db_block_lru_lru_latches or multiple buffer pools</TD></TR>
  </TABLE>
  <P>Again, these are potential fixes, not general solutions. More information can
  be found on the help page about <A HREF="latchfree.html">Latch Free Waits</A></P>
</TD></TR></TABLE>

</BODY></HTML>
