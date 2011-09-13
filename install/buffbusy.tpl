<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Buffer busy waits happen when a session needs to access a database block
    in the buffer cache but cannot, because the buffer is "busy". The two
    main cases where this can occur are:</P>
 <UL>
   <LI>Another session is reading the block into the buffer</LI>
   <LI>Another session holds the buffer in an incompatible mode to this
       request (the buffer is locked)</LI>
 </UL>
 <P>Affected segments can be found in the Segment Statistics block of the
    report, in the <I>Top N Buffer Busy Waits per Segment</I> table to be more
    precise &ndash; whereas the waits themselves are listed in the corresponding
    sections, e.g. in the <I>Related Information</I> for the database writer
    or the <I>Top N Waits</I>.
 <P>Frequent buffer busy waits on the same segments usually indicate "hot
    blocks" &ndash; this is either a single row of data frequently
    changed by concurring processes, or a number of rows sharing the
    same data block and being frequently updated by concurring sessions.
    In the latter case, the use of reverse key indexes may help reducing
    these waits.</P>
 <P>More details on buffer wait statistics can also be found in the <I>Shared
    Pool Statistics</I> and are explained in
    <A HREF='buffwaits.html'>this help document</A>.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
