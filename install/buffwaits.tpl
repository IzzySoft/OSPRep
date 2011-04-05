<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>If Waits/s are high for a given class, you may consider some tuning:</P><UL>
 <LI><B>Segment Header:</B> increase freelists / freelist groups, increase the
     pctfree-to-pctused gap. Consider ASSM to let Oracle take care for this
     automatically. For the Oracle Parallel Server, make sure each instance
     has its own freelist groups.</LI>
 <LI><B>Undo Header:</B> add rollback segments or increase the undo area.</LI>
 <LI><B>Undo Block:</B> Commit more often (but not too often, or you simply convert
     this wait into "log file sync" waits). Use larger rollback segments or
     undo areas. Increase <CODE>DB_CACHE_SIZE</CODE>.
 <LI><B>Data Block:</B> Reduce the number of rows per block (e.g. use smaller
     blocks, adjust pctused/pctfree) to make blocks "less hot". Use partitioning
     (for large tables and indexes) to avoid unnecessary scans. Increase
     <CODE><A HREF="initrans.html">INITRANS</A></CODE> (but not too much) for
     the hot block(s) to allow for multiple ITL slots, consider using ASSM
     (Automatic Segment Space Management) if it is not already active (introduced
     with 9i, default for new tablespaces since 10g). Increasing the size of
     the database buffer cache can reduce these waits as well.</LI>
 <LI><B>Index Block:</B> Reduce the number of rows per block (see above).
     Consider reverse-key indexes. Rebuild indexes. Increase <CODE>INITTRANS</CODE>
     (see above). Check for unselective indexes (bad code / bad indexes).</LI>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
