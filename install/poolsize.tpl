<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'> 
 <TITLE>OraHelp: Pool Sizes</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Pool Sizes</H3>
 <P>Correct sizing of the pool areas is one of the major tasks affecting the database
    performance. Hence here are a few hints on the different pool types and things to
    consider about their sizes. You can use the dynamic <CODE>DB_CACHE_ADVICE</CODE>
    parameter with statistics gathering enabled to predict behavior with different
    cache sizes through the <CODE>V$DB_CACHE_ADVICE</CODE> performance view.</P>
 <H4><A NAME="sp"></A>The Shared Pool</H4>
 <P>The shared pool contains shared cursors, stored procedures, control structures,
    and other structures. A larger shared pool significantly improves performance
    especially in a multi-user-environment -- but of course it also uses more memory.
    Inadequate sizing may result in <CODE>ORA-04031</CODE> errors. This error may
    allude to either the shared or the large pool.</P>
 <TABLE BORDER="1" WIDTH="95%" STYLE="margin:5px" ALIGN="center">
   <TR><TH CLASS="th_sub">Parameter</TH><TH CLASS="th_sub">Comment</TH></TR>
   <TR><TD><CODE>SHARED_POOL_SIZE</CODE></TD>
       <TD>Over all size of the shared pool. There is no general recommendation for
           the overall size of the shared pool, since many criteria influence this
           (amount of simultaneous users, size of the database...). For a medium
           sized database, about 1 megabyte may be a good value to start with.</TD></TR>
   <TR><TD><CODE>SHARED_POOL_RESERVED_SIZE</CODE></TD>
       <TD>This specifies the size of the shared pool which is reserved for larger
           objects. The target for this is to avoid the situation, that because of
           a fragmentation of the shared pool due to many small objects, we cannot
           find a contiguous place to store our large object. As a rule of thumb,
           some FAQs recommend to set this parameter to about half the value of
           <CODE>SHARED_POOL_SIZE</CODE> (Oracle default is only 5%).</TD></TR>
   <TR><TD><CODE>_SHARED_POOL_RESERVED_MIN_ALLOC</CODE></TD>
       <TD>Above we talked about "large" and "small" objects. This parameter
           specifies the minimum size to call some object "large". All objects
           from this size on will be stored in the reserved area, smaller ones go
           to the remainung part of the shared pool. <B><I>This is an undocumented
           parameter, so normally you shouldn't (need to) alter it.</I></B> The default
           is (as far as I know) 4.400. Some FAQs mention a useful value to start
           with for this parameter as 2.500. More details on this parameter you can
           find at Oracle Metalink using the DocId for Note 146599.1.<BR>
           Oracle 10g provides a new feature called "automatic memory management". If
           you use that, you don't need to adjust all the values listed here ;)</TD></TR>
 </TABLE>
 <H4>The Large Pool</H4>
 <P>The <CODE>LARGE_POOL_SIZE</CODE> specifies the size in bytes of the large pool used
    in shared server systems for session memory, parallel execution for message buffers,
    and by backup and restore processes for disk I/O buffers. By default, the large pool
    is switched off (if the pool is not required by parallel execution, and the parameter
    <CODE>DBWR_IO_SLAVES</CODE> is not set) -- which means that Oracle uses the shared pool
    instead. If you activate the large pool its size must be large enough, otherwise some
    processes (e.g. also <CODE>RMAN</CODE>) may fail.</P>
 <P>In contrast to the shared pool which uses LRU lists for its memory management, the
    large pool uses a heap (with <i>allocate</i> and <i>free</i>). So after all, in my
    opinion it is better to first try defining an appropriate
    <CODE>SHARED_POOL_RESERVED_SIZE</CODE> (see <A HREF="#sp">above</A>) instead if you
    need an area for larger objects.</P>
 <H4>The Buffer Cache</H4>
 <P>The Parameter <CODE>DB_CACHE_SIZE</CODE> (Oracle 9i and up) specifies the size in bytes
    of the buffer cache (the old parameter <CODE>DB_BLOCK_BUFFERS</CODE> is deprecated
    for Oracle 9i and up, but specifies the same area in Oracle blocks for Oracle up to
    version 8i -- to know the size in bytes you need to multiply this with the block size
    used. Other than the Oracle 9i+ parameter, the Oracle 8i parameters are static, which
    means that a change requires a restart of the instance. This applies to all 3 parameters
    in the table below).</P>
 <P>This dynamic parameter controls the default pool, where by default all tables are
    assigned to. To gain a better performance, you may want to create multiple buffer
    pools for special issues, and explicitly assign your tables to these pools using the
    <CODE>ALTER TABLE</CODE> statement with the appropriate storage clause
    (<CODE>BUFFER POOL &lt;pool&gt;</CODE>). The following pools you can use:</P>
 <TABLE BORDER="1" WIDTH="95%" STYLE="margin:5px" ALIGN="center">
   <TR><TH CLASS="th_sub" WIDTH="80">Pool</TH><TH CLASS="th_sub">Oracle 8i</TH>
       <TH CLASS="th_sub">Oracle 9i+</TH><TH CLASS="th_sub">Comment</TH></TR>
   <TR><TD>Default Pool</TD><TD><CODE>DB_BLOCK_BUFFERS</CODE></TD>
       <TD><CODE>DB_CACHE_SIZE</CODE></TD><TD>See above</TD></TR>
   <TR><TD>Keep Pool</TD><TD><CODE>BUFFER_POOL_KEEP</CODE></TD>
       <TD><CODE>DB_KEEP_CACHE_SIZE</CODE></TD>
       <TD>This cache is intended for frequently used objects like lookup tables. You should
           explicitely assign such tables to this pool.</TD></TR>
   <TR><TD>Recycle Pool</TD><TD><CODE>BUFFER_POOL_RECYCLE</CODE></TD>
       <TD><CODE>DB_RECYCLE_CACHE_SIZE</CODE></TD>
       <TD>This is for objects you use very rarely. These you also should explicitely
           assign here.</TD></TR>
 </TABLE>
 <P>Every object that is not explicitely assigned to any pool automatically goes into the
    default pool. But if you now have partitioned your buffer cache (and modified your
    objects accordingly), none of your rarely used objects will age out any more frequent
    used ones from the cache, since they are using different cache partitions (and thus
    different MRU lists), which will result in enhanced performance.</P>
 <H4>The Log Buffer</H4>
 <P>With the <CODE>LOG_BUFFER</CODE> parameter in the <CODE>init.ora</CODE> you define the
    buffer for redo entries (before they are written to the redo log file). Other than the
    parameters above, this is a static parameter and only can be changed by restarting the
    instance.</P>
 <P>Two things cause the redo log to be written to disk: When a transaction commits, or when
    the log buffer is full and new entries need space here. For the latter, a large value
    for the <CODE>LOG_BUFFER</CODE> parameter reduces the I/O overhead by allowing more data
    to be flushed per write. Moreover, waits that occur when redo entries are flushed to make
    space in the log buffer pool can be avoided.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
