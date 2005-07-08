<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Buffer hit ratio</TITLE>
</HEAD><BODY>

<H3>Controlling the buffer hit ratio</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>If the buffer hit ratio is markably low (i.e. less than 70..90%), this
    indicates a need of optimization for the buffer cache. There are several
    options amongst which can be chosen (or which can be combined) to gain
    better results:</P>
 <P><CODE>DB_BLOCK_BUFFERS</CODE>: You simply could increase this value to
    allow your database to store more information (remember: The buffer cache
    is used to cache information normally stored in your datafiles for
    subsequent use; and of course, normally you cannot store all your data
    here). If you do so, use reasonable values -- otherwise you may force
    your system to swap, which again will decrease the performance. So when
    you decide to increase the size of the buffer cache, you may want to start
    adding, say, 20% of the size already assigned, and then evaluate the
    performance gain.</P>
 <P>Use multiple buffer pools for different object types. Starting with Oracle
    8i, you can divide the buffer cache into 3 different areas:</P>
    <UL><LI><CODE>DB_KEEP_CACHE_SIZE</CODE> (Oracle 9i+) resp. <CODE>BUFFER_POOL_KEEP</CODE>
            (Oracle 8i)</LI>
        <LI><CODE>DB_RECYCLE_CACHE_SIZE</CODE> (Oracle 9i+) resp.
            <CODE>BUFFER_POOL_RECYCLE</CODE> (Oracle 8i)</LI></UL>
    <P>The third area is the remaining space of the buffer pool, the default pool.
    When you have set these parameters, you should check your objects for their
    default pool assignment. If there is none, they will be loaded into the default
    pool. You can explicitly assign a different pool with the <CODE>BUFFER POOL
    KEEP</CODE> or <CODE>BUFFER POOL RECYCLE</CODE> clause of the <CODE>CREATE
    TABLE</CODE> resp. <CODE>CREATE INDEX</CODE> command. This way you can e.g.
    load frequently used small lookup tables into the keep pool or other rarely
    used tables/indices into the recycle pool, and hence influence the hit ratio.</P>
    <P>One thing to mention: While you still can use the 8i parameters with a 9i
    database (they are deprecated but still kept for compatibility), you should not
    mix between 8i/9i parameters here. With a 9i database, you are better off using
    the new parameters, which additionally gives you the ability to adjust these
    sizes using the <CODE>ALTER SYSTEM</CODE> command, to find out their right sizes
    before fixing them into the <CODE>init.ora</CODE> file.</P>
 <P><CODE>DB_BLOCK_LRU_LATCHES</CODE>: This value is set automatically by Oracle
    starting with version 9i. In Oracle 8i, increasing this value may help as well,
    since then more LRU lists are available.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
