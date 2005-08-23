<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Sorts</TITLE>
</HEAD><BODY>

<H3>In Memory Sort Ratio</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>A too low ratio indicates too many disk sorts appearing. If it is high and
 unacceptable, check the followings:</P><UL>
 <LI>One possible solution could be increasing the sort area/SGA size.</LI>
 <LI>Avoid unnecessary use of sort related clauses such as <CODE>ORDER BY</CODE>,
     <CODE>GROUP BY</CODE>, <CODE>CONNECT BY</CODE>, <CODE>DISTINCT</CODE>.</LI>
 <LI>Don't use <CODE>UNION</CODE> clause if there is no need to eliminate duplicate
     rows. Use <CODE>UNION ALL</CODE> instead.</LI>
 <LI>Check execution plans which includes high amount of sorted rows.</LI></UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
