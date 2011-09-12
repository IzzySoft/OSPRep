<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
 <TITLE>OSPRep Help: INI_TRANS / MAX_TRANS</TITLE>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
</HEAD><BODY>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Each datablock has a number of transaction entries that are used for row
  locking purposes. Initially, this number is specified by the
  <code>INI_TRANS</code> parameter; the default value (1 for tables, 2 for
  indices) is generally sufficient. However: if a table (or index) is known to
  have many rows for each block with a high possibility of many concurrent
  updates, it is beneficial to set a higher value - which must be done at the
  <code>CREATE TABLE/CREATE INDEX</code> time to have it set for all blocks
  of the object.</P>
 <P>So how do you know whether sone object needs adjustment here? Either your
  planning and design of the database did foresee, or your performance report
  gave you indications: if an object has either many <code>buffer busy get</code>s,
  or is subject to <code>TX enqueue waits</code>, you have found a candidate for
  adjustment.</P>
 <TABLE WIDTH="95%" ALIGN="center" BORDER="1">
   <TR><TD CLASS="td_name" ROWSPAN="2">Recommended values:</TD>
       <TD CLASS="inner" STYLE="text-align:justify">[# of CPUs] &lt;= <code>INI_TRANS</code> &lt; 100</TD></TR>
   <TR><TD CLASS="inner" STYLE="text-align:justify"><code>MAX_TRANS</code> &lt; 100</TD>
   <TR><TD CLASS="td_name">Side-Effects:</TD>
       <TD CLASS="inner" STYLE="text-align:justify">If the value for either of these parameters is too high,
           Oracle will use more space for the transaction layer block header
           and less for the data layer variable header; this can result in more
           I/O.</TD></TR>
 </TABLE>
 <P>Starting with Oracle 10g, <CODE>MAXTRANS</CODE> is deprecated and no longer
    honored.</P>
 </TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
