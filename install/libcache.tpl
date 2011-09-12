<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Library Cache</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Library Cache</H3>
 <P><I>Pct Miss</I>es should be very low. If they exceed 10%, your SQL
  statements may use unsharable SQL. You can fix this by either using bind
  variables or by the <CODE>cursor_sharing</CODE> statement in your
  <CODE>init.ora</CODE>. Available values to this parameter are:</P>
  <DIV ALIGN="center" STYLE="margin-bottom:5px"><TABLE BORDER="1" WIDTH="95%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">Value</TH><TH CLASS="th_sub">Comment</TH></TR>
   <TR><TD CLASS="td_name">exact</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Only Statements with identical text are allowed to share
           a cursor (Default)</TD></TR>
   <TR><TD CLASS="td_name">similiar</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Statements that may differ in some literals but are
           otherwise identical are caused to share a cursor, unless the
           literals affect either the meaning of the statement or the degree to
           which the plan is optimized (I recommend this for e.g. a low soft
           parse ratio or high library cache getmiss ratio).</TD></TR>
   <TR><TD CLASS="td_name">force</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Even statements that may differ in some literals but
           are otherwise identical are forced to share a cursor, unless the
           literals affect the meaning of the statement (since this also means
           the optimizer cannot predict precise selectivity you should think
           twice before using this)</TD></TR>
  </TABLE></DIV>
 <P>Since this parameter is dynamic, you may use <CODE>ALTER SYSTEM</CODE> to
  change its value without restarting the instance.</P>
 <P>Other things one might check include:</P><UL>
   <LI>providing a larger library cache by increasing the value of the
       <CODE>SHARED_POOL_SIZE</CODE> initialization parameter</LI>
   <LI>make sure identical statements are spelled identical: additional
       white spaces or different cases (upper/lower) make them different
       to Oracle. For example, <CODE>SELECT * FROM emp</CODE>,
       <CODE>SELECT&nbsp;&nbsp;*&nbsp;&nbsp;FROM emp</CODE> and
       <CODE>select * from emp</CODE> would be considered different
       statements and thus both saved to the cache separately.<BR>
       This also includes Bind variables: <CODE>WHERE name=:name</CODE>
       is not identical to <CODE>WHERE name=:surname</CODE>, though
       this should be selfunderstanding.</LI>
   <LI>think about using stored procedures/packages. This not only
       ensures the executed SQL will always be spelled identical (see
       previous point) &ndash; as stored procedures/packages are stored
       in a parsed form, it as well eliminates the need of runtime parsing.</LI>
   <LI>if there are no cache misses (and only then), you may evaluate the
       possibility to set <CODE>CURSOR_SPACE_FOR_TIME</CODE> to <CODE>TRUE</CODE>,
       which prevents active cursor statements to be purged from the cache and
       thus may further improve your application performance.</LI>
   <LI>if you see an application parsing the same SQL statement multiple times,
       you may take a look at the <CODE>SESSION_CACHED_CURSORS</CODE> setting,
       which can be altered dynamically at session level using the
       <CODE>ALTER SESSION SET</CODE> command. The value is a positive
       integer, indicating the amount of cursors to cache. Oracle then will
       automatically determine which cursors to cache, and purge them out
       using a LRU (last-recently-used) algorithm.</LI>
 </UL>

 <P>Another important statistic to look at is the number or <I>RELOADS</I>. If there
  are significant number of <I>RELOADS</I>, then reusable information is being
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

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
