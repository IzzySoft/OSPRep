<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: File IO</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>File I/O and TableSpace I/O</H3>
 <P>If the value for Avg Blks/Rd is higher than 1, this indicates full table
  scans. If it grows higher than <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> we
  must assume that almost every operation on this TS is executed as full table
  scan instead of using an index first, so you should consider creating
  appropriate indices or, maybe, increasing the
  <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE>.</P>
 <P>Note that increasing the <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> may have
  some side effects on the optimizer: it may then prefer a full table scan in
  some cases you may not like it. Having proper indexes on the other side can
  never hurt, so I'ld suggest starting at that point.</P>
 <P>Average Read Times (AvgRd) of greater than 20..40ms should be considered
  slow for single block reads. So if this is the case, you should check whether
  the disks are capable of the required IO rates. If they are, your
  file-to-disk layout may be causing some disks to be underused while others
  are overly busy. Furthermore, if the temporary TableSpaces have the most
  write activity, this may indicate that too much of the sorting is to disk
  and may require optimization.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2004 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
