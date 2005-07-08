<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Soft Parse</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>A soft parse occurs when a session attempts to execute a SQL statement and
  a usable version of the statement is already in the shared pool, so the
  statement can be executed immediately. The hard parse is the opposite and an
  expensive operation. When the soft parse ratio falls much below 80%,
  investigate whether you can share SQL by using bind variables or force cursor
  sharing by using the <CODE>init.ora</CODE> parameter <CODE>cursor_sharing</CODE>
  (new in Oracle8i Release 8.1.6). Available values are:</P>
  <TABLE ALIGN="center" BORDER="1" WIDTH="95%" STYLE="margin:5px">
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
  </TABLE>
 <P>Since this parameter is dynamic, you may use <CODE>ALTER SYSTEM</CODE> to
  change its value without restarting the instance.</P>
 <P>But before drawing any conclusions, compare the soft parse ratio against
  the actual hard and soft parse rates shown in the Loads Profile. If the rates
  are low, parsing may not be a significiant issue in your system. Furthermore,
  investigate the number of Parse CPU to Parse Elapsed below. If this value is
  low, you may rather have a latch problem.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
