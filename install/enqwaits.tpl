<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Enqueue Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Below you find a description on selected enqueue types:</P>
 <TABLE BORDER="0">
  <TR><TD CLASS="smallname">BL</TD>
      <TD><B>Buffer Cache Managment</B></TD></TR>
  <TR><TD CLASS="smallname">CF</TD>
      <TD><B>Control file schema</B> global enqueue</TD></TR>
  <TR><TD CLASS="smallname">CI</TD>
      <TD><B>Cross Instance</B> call invocation</TD></TR>
  <TR><TD CLASS="smallname">CU</TD>
      <TD><B>Cursor Bind</B></TD></TR>
  <TR><TD CLASS="smallname">DF</TD>
      <TD><B>Datafile</B></TD></TR>
  <TR><TD CLASS="smallname">DL</TD>
      <TD><B>Direct Loader</B> index creation</TD></TR>
  <TR><TD CLASS="smallname">DR</TD>
      <TD><B>Distributed Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">DX</TD>
      <TD><B>Distributed Transactions</B></TD></TR>
  <TR><TD CLASS="smallname">IR</TD>
      <TD><B>Instance Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">HW</TD>
      <TD><B>Space Management</B> operations on a specific
          segment. This enqueue is used to serialize the allocation of space
	  above the high water mark of a segment:<BR>
	  <CODE>V$SESSION_WAIT.P2 / V$LOCK.ID1</CODE> is the tablespace number<BR>
	  <CODE>V$SESSION_WAIT.P2 / V$LOCK.ID2<CODE> is the relative dba segment
	  header of the object for which space is being allocated<BR>
	  If this is a point of contention for an object, then manual allocation
	  of extents solves the problem.</TD></TR>
  <TR><TD CLASS="smallname">LA..LP</TD>
      <TD><B>Library Cache</B> Lock</TD></TR>
  <TR><TD CLASS="smallname">MD</TD>
      <TD><B>Materialized Views:</B> enqueue for change data capture
          materialized view log (gotten internally for DDL on a snapshot
	  log); id1=object# of the snapshot log.</TD></TR>
  <TR><TD CLASS="smallname">NA..NZ</TD>
      <TD><B>Library Cache</B> Pin</TD></TR>
  <TR><TD CLASS="smallname">SQ</TD>
      <TD><B>SeQuences</B> not being cached, having a to small
          cache size or being aged out of the shared pool. Consider pinning
	  sequences or increasing the shared_pool_size.</TD></TR>
  <TR><TD CLASS="smallname">ST</TD>
      <TD><B>Space management locks</B> could be caused by using
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
  <TR><TD CLASS="smallname">TA</TD>
      <TD><B>Transaction Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">TM</TD>
      <TD><B>Table locks</B> point to the possibility of e.g.
          foreign key constraints not being indexed</TD></TR>
  <TR><TD CLASS="smallname">TX</TD>
      <TD><B>Transaction locks</B> indicate multiple users try
          modifying the same row of a table (row-level-lock) or a row that is
	  covered by the same bitmap index fragment, or a session is waiting
	  for an ITL (interested transaction list) slot in a block, but one or
	  more sessions have rows locked in the same block, and there is no
	  free ITL slot in the block. In the first case, the first user has to
	  <CODE>COMMIT</CODE> or <CODE>ROLLBACK</CODE> to solve the problem. In
	  the second case, increasing the number of ITLs available is the
	  answer - which can be done by changing either the
	  <A HREF="initrans.html"><CODE>INITRANS</CODE> or <CODE>MAXTRANS</CODE></A>
	  for the table in question.</TD></TR>
  <TR><TD CLASS="smallname">US</TD>
      <TD><B>Undo Segment</B>, serialization</TD></TR>
 </TABLE>
 <P>For more information on enqueue waits, see <A HREF="enqueue.html">Enqueues</A>.</P>

</TD></TR></TABLE>
</BODY></HTML>
