<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
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
 <P>An important statistic to look at is the number or <I>RELOADS</I>. If there
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
