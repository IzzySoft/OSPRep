<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Library Cache</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <H3>Library Cache</H3>
 <P><I>Pct Miss</I>es should be very low. If they exceed 10%, your SQL
  statements may use unsharable SQL. You can fix this by either using bind
  variables or by the <CODE>cursor_sharing=FORCE</CODE> statement in your
  <CODE>init.ora</CODE>.</P>
 <P>An important statistic to look at is the number or <I>RELOADS</I>. If there
  are significant number of <I>RELOADS</I>, then reusuable information is being
  aged out of the SGA, and hence having to be reloaded and rebuilt. This
  indicates the shared pool may need attention (which may include resizing,
  changing large pool, pinning objects etc).</P>
 <P>Also look for a high number of <I>invalidations</I>. An invalidation occurs
  when an object in the library cache is determined to be no longer valid for
  execution or reference; this housekeeping is done automatically by Oracle.
  One situation where objects are invalidated is when executing DDL operations
  frequently. The effects of invalidations can be reduced by executing DDL
  statements during off peak periods.</P>
</TD></TR></TABLE>

</BODY></HTML>
