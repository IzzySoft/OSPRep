<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Potential Fixes for indicated Latch problems are:
  <TABLE ALIGN="center" WIDTH="90%" BORDER="1">
   <TR><TH CLASS="th_sub">Latch</TH><TH CLASS="th_sub">Potential Fix</TH></TR>
   <TR><TD>library cache and shared pool latches</TD>
       <TD>adjusting the <CODE>shared_pool_size</CODE> and use of bind
           variables / set cursor_sharing parameter in your
           <CODE>init.ora</CODE></TD></TR>
   <TR><TD>redo allocation latches</TD>
       <TD>minimize redo generation and avoid unnecessary commits</TD></TR>
   <TR><TD>redo copy latches</TD>
       <TD>increase the <CODE>log_simultaneous_copies</CODE></TD></TR>
   <TR><TD>row cache objects latches</TD>
       <TD>increase the <CODE>shared_pool_size</CODE></TD></TR>
   <TR><TD>cache buffer chain latches</TD>
       <TD>adjust _db_block_hash_buckets</TD></TR>
   <TR><TD>cache buffer latches</TD>
       <TD>use _db_block_lru_lru_latches or multiple buffer pools</TD></TR>
  </TABLE>
  Again, these are potential fixes, not general solutions. More information can
  be found on the help page about <A HREF="latchfree.html">Latch Free Waits</A></P>
</TD></TR></TABLE>

</BODY></HTML>
