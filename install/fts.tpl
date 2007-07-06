<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: FTS Analysis</TITLE>
</HEAD><BODY>

<H3>FTS Analysis</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Generally spoken, a "Full Table Scan" (FTS) must not necessarily indicate
  something bad: If it is a very small table, it is normal - and the same
  applies if you need all data from any table. But on average, more than 50% of
  all FTS in the database indicate some performance issues, such as missing or
  wrong indexes, or badly designed queries. To find those, the FTS module
  provides its help.</P>
 <P>The FTS module collects all statements that performed full table scans and
  have been encountered during the given SnapShot interval, orders them by what
  Oracle calls "cost" (the worst being the first), gathers some additional data
  such as execution plan, number of executions, buffer gets, disk reads, etc.,
  and puts them in a nice HTML table - which can become quite large. So if you
  are in the middle of the table, you may not be sure which column holds which
  value: Move the mouse over it, and a hint should be displayed (if your browser
  supports the TITLE attribute).</P>
 <P>Now for the interpretation: You may notice some statements with 0 executions,
  0 buffer gets, etc. Don't be confused with them, it's not my fault. The cause
  normally is that the data on the first and last appearance of the statement
  during the snapshot interval have been identical (e.g. Oracle claims 1
  execution at snapshot 10, and on snapshot 20 the statement appears again, still
  stating 1 execution cumulative). This <i>may</i> be due to the fact that the
  statement has just been parsed but not executed on the second call (e.g. if
  you just retrieved the execution path, but did not run the query). It may as
  well be some other reason - remember, the RDBMS is called "Oracle", and not
  "Locigal answer"...</P>
 <P>Here are some hints on the interpretation:</P><UL>
  <LI>The "cost" criteria, by which the statements are ordered, is not very
      reliable (as experiences showed). So don't get wound up in checking for
      the first statement(s) of the table.</LI>
  <LI>A statement executed more often invites your focus, since it snatches
      resources more often which may slow down other processes.</LI>
  <LI>A high number of disk reads indicates a statement worth to focus on. On
      the other hand, a statement with many buffer gets but no (or only few)
      disk reads may not be that important: This combination just indicates
      that your "cache" is working fine, and Oracle reads the data from
      memory instead of disk.</LI>
  <LI>CPU time and Elapsed time are good indicators for longrunners. If they are
      high and go together with many disk reads, you just found a statement you
      should for sure take a closer look at.</LI>
  <LI>The module column helps you find out who possibly ran the statement.
      Depending on your environment, something like "PL/SQL Developer" or
      "sqlplus.exe" may show you that it possibly was one of your developers
      or DBA trying something manually, and it's not worth to check that
      statement - while the name of your application(s) indicate productive
      usage and should be investigated.</LI>
  <LI>All values are cumulative, i.e. summed up for all executions in the given
      SnapShot interval. So if you got shocked by a 10-digit CPUTime, remember
      to divide it by the "executions" value to get CPUTime/Execution</LI></UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
