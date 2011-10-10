<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Library Cache</TITLE>
</HEAD><BODY>

<H3>Long running statements</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>If a statement requires a lot of time to be processed, this can be caused
    by different things. To figure out what may apply, you can use the different
    data provided in the statistical overview for the statement. For a start,
    you may want to walk down the following list until you find a match to
    your situation. The closer the match, the less likely are multiple causes.</P>
 <UL>
   <LI><B><I>CPU per Exec</I> comes close to <I>Elap per Exec</I>:</B>
       This goes along with a high CPUCost (shown in the execution plan) and usually
       points to a lot of sort and join operations. For optimization, you may want
       to look out for unnecessary joins (eliminate tables not really needed from the
       query). You will probably need all of them; so if large tables are part of
       the game, you could investigate into possible partitioning to limit the amount
       of data involved and enhance parallelism.<BR>
       Sorts are not restricted to the <CODE>ORDER BY</CODE> clause, but also take
       place for e.g. <CODE>GROUP BY</CODE>, so you may check these as well.<BR>
       Moreover, the CPU could have been kept busy looking for free buffers, if
       the DBWriter was unable to keep up with changes. You may check the <I>Database
       Writer Statistics</I> for details on this.<BR>
       Furthermore, have a look at the help on <A HREF='cputime.html'>CPUTime</A>.</LI>
   <LI><B><I>Reads per Exec</I> is high:</B> This usually goes along with high
       IOCost (shown in the execution plan) and indicates quite a lot of data being
       processed. Look out for Full Table Scans on bigger tables (missing indexes?),
       or inappropriate indexes being used. Partitioning may also kick in here to
       reduce the amount of data to be read (in this case, most likely range partitioning).</LI>
   <LI>Neither of the above: If it didn't read data nor processed them, it probably
       had to wait a lot for ressources. Together with a high number of <I>Executions</I>,
       one of the objects in the execution plans probably will show up in the segment
       statistics (for one of the Top Waits) for you to check upon.</LI>
   <LI><B>Rows per Exec</B> simply gives you an idea of the average result set size.
       If this falls well below 1 for a <CODE>SELECT</CODE> statement (with a high number
       of <I>Executions</I>), in many cases there are no rows returned &ndash; so in your
       application logic, you might want to add a simpler check on wether there is data
       available at all before executing this complex query.</LI>
 </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
