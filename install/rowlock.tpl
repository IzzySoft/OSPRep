<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: RollBack Stats</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are Row Lock Waits?</H3>
 <P>Row lock waits occur when a process requests an incompatible lock for a
    row that is currently locked by another process. This usually happens
    when high volume inserts/updates happen on tables with unique indexes
    (as most tables will have a primary key index: that is such a unique index),
    and are issued by multiple processes.</P>
 <H3>How to avoid or at least minimize these waits?</H3>
 <P>You will probably not be able to avoid them altogether, and I do not know
    of any "patent recipe". Some things that <I>could</I> help include...</P>
 <UL>
    <LI>using reverse-key indexes</LI>
    <LI>partitioning of the affected table (and indexes)</LI>
    <LI>checking your application logic, e.g. serialize imports instead
        of running them simultaneously</LI>
 </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
