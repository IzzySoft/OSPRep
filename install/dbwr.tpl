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
</TD></TR><TR><TD CLASS="text">
 <P>The following table gives you more details on the DBWR statistics displayed in the
    report:</P>
  <TABLE ALIGN="center" BORDER="1" WIDTH="99%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Details</TH></TR>
   <TR><TD CLASS="td_name">DBWR transaction table writes / hour</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Number of rollback segment headers
           written per hour by DBWR. This statistic indicates how many "hot" buffers
           were written, causing a user process to wait while the write completed.</TD></TR>
   <TR><TD CLASS="td_name">DBWR revisited being-written buffer / hour</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Number of times per hour that DBWR
           tried to save a buffer for writing and found that it was already in the write
           batch. This statistic measures the amount of "useless" work that DBWR had to
           do in trying to fill the batch. (If the same buffer from different sources is
           considered for adding to the write batch, then all but the first attempt will
           be "useless" because the buffer is already marked as being written.)</TD></TR>
   <TR><TD CLASS="td_name">pinned buffers inspected / DBWR buffers scanned</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This ratio should be as low as possible.
           If this value is high, it indicates high amount of pinned (busy) buffers
           encountered during free buffer search. This may cause <i>free buffer waits</i>
           event by reducing the possibility of finding free buffer in the LRU list, and
           then may cause DBWR to perform large batch write to make clean buffers available
           at the tail of LRU list. This may also increase physical IO if aged out blocks
           are needed to be re-accessed.<BR>
           A possible solution is to increase the <CODE>DB_BLOCK_BUFFERS</CODE> (Oracle 8)
           / <CODE>DB_CACHE_SIZE</CODE> (Oracle 9+).</TD></TR>
   <TR><TD CLASS="td_name">DBWR free buffers found / DBWR make free requests</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This ratio shows the average reusable
           buffers, and should be as high as possible. If it is low, it indicates lack of
           free space to use. In this case, check the followings:<UL>
             <LI>If <I>dirty buffers inspected</I> is high, it indicates DBWR is not writing
                 dirty buffers efficiently.</LI>
             <LI>If <I>pinned buffers inspected</I> is high, increase <CODE>DB_BLOCK_BUFFERS</CODE>
                 / <CODE>DB_CACHE_SIZE</CODE>.
           </UL></TD></TR>
   <TR><TD CLASS="td_name"></TD>
       <TD CLASS="inner" STYLE="text-align:justify"></TD></TR>
  </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
