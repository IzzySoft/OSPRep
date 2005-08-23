<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Speed-Up DBWR</TITLE>
</HEAD><BODY>

<H3>How to speed up the DBWR</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>These are some general hints which may help to speed up the DBWR process:</P>
 <UL>
  <LI>Check for missing indices. Getting unrelated blocks may cause other blocks aged out.</LI>
  <LI>Consider implementing DBWR IO slaves or multiple DBWRs.</LI>
  <LI>Use Parallel Query(PQ). PQ slaves in direct read can read blocks into process
      private memory bypassing buffer cache. When PQ slaves do direct read, other blocks
      are not aged out from buffer cache by PQ operations. This reduces workload on DBWR.
      But, if PQ slaves need to read dirty buffers, Oracle has to write dirty buffers to
      disk before PQ starts for read-consistency reason. Then, PQ reads them from disk.</LI>
  <LI>Don't set <CODE>CACHE</CODE> option on full scanned large tables if they are not used
      frequently. Setting <CODE>CACHE</CODE> option on large tables may cause other blocks
      are aged out.</LI>
  <LI>Increase <CODE>DB_BLOCK_BUFFERS</CODE> (Oracle 8) / <CODE>DB_CACHE_SIZE</CODE>
      (Oracle 9+). But, be careful: Oracle accepts table as short table if table size is
      less than 2% of <CODE>DB_BLOCK_BUFFERS</CODE>. In fact, it can not be short if
      <CODE>DB_BLOCK_BUFFERS</CODE> / <CODE>DB_CACHE_SIZE</CODE> is too high. Since short
      tables are placed at the head of the LRU, it's very likely for other blocks to be
      aged out if short tables are not short indeed.</CODE>
  <LI>Use multiple buffer pools and design your object accordingly using the correct
      storage clause. This way you can keep frequently used objects in the keep pool,
      while less frequently used ones aging out the default or recycle pool only.</LI>
 </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
