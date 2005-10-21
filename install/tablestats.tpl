<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Table Statistics</TITLE>
</HEAD><BODY>

<H3>Table Statistics</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Depending on your configuration settings in the <code>config</code> file, this
    statistic segment may contain up to 3 blocks. While the first block always
    contains some important ratios (details below), the other two blocks will show
    some simple statistics. Here is some more detailed information for the
    evaluation of your results:</P>
  <TABLE ALIGN="center" BORDER="1" WIDTH="95%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Details</TH></TR>
   <TR><TH CLASS="th_sub2" COLSPAN="2">Ratios</TH></TR>
   <TR><TD CLASS="td_name">blocks scanned per scanned row</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This ratio should get close to 0 with
           acceptable table scan blocks gotten if you are not using LONG objects frequently.
           If it is high, you probably should:<UL>
           <LI>Check missing index(es) on statements doing Full Table Scan(FTS).</LI>
           <LI>If Statements have to do FTS, reorganize tables used in FTS to reset High
               Water Mark(HWM). Because, in FTS, Oracle scans table from bottom of table
               to top of table(HWM) even if there are just a few rows in table. This makes
               problems on frequently inserted/deleted tables since <CODE>INSERT</CODE>
               increases HWM, but <CODE>DELETE</CODE> does not decrease HWM. After
               reorganization, the number of scanned blocks will be reduced.</LI></UL></TD></TR>
   <TR><TD CLASS="td_name">chained-fetch-ratio</TD>
       <TD CLASS="inner" STYLE="text-align:justify">The chained-fetch-ratio indicates the
           average chained/migrated rows in multiple blocks, which are accessed by a single
           ROWID. This ratio should be as low as possible to access a row in a single block.
           If it is high,<UL>
           <LI>find the chained/migrated rows (the <code>analobj.sh</code> script from
               the DBAHelper archive, which you also find at <A HREF="http://www.izzysoft.de/"
               TARGET="_blank">IzzySoft</A>, can help you here)</LI>
           <LI>increase <CODE>PCTFREE</CODE>, decrease <CODE>PCTUSED</CODE> storage parameters
               of tables which have many chained/migrated rows frequently used</LI>
           <LI>reorganize these tables (e.g. <CODE>ALTER TABLE..MOVE</CODE>, or
               <CODE>EXP</CODE> / <CODE>IMP</CODE>)</LI></UL></TD></TR>
   <TR><TH CLASS="th_sub2" COLSPAN="2">Table Scans</TH></TR>
   <TR><TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">If we have many full table
       scans, we may have to optimize <CODE>DB_FILE_MULTI_BLOCK_READ_COUNT</CODE>. Beneath
       the statistic below, we need the block count of the largest table to find the best
       value. A common recommendation is to set <CODE>DB_FILE_MULTI_BLOCK_READ_COUNT</CODE>
       to the highest possible value for maximum performance, which is 32 (256k) in most
       environments. The absolute maximum of 128 (1M) is mostly only available on raw devices.</TD></TR>
   <TR><TH CLASS="th_sub2" COLSPAN="2">Extents Needed</TH></TR>
   <TR><TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">Unless you have a rather
       misconfigured table(space) layout, you probably will not need to enable this third
       block. When you configured your table(space)s with properly initial and next extent
       sizes, a dynamic allocation should not cause that much I/O on your database that you
       need to care about. For heavily growing tables, don't use e.g. only 64k next extent
       size (this would cause repeated single allocations), but rather some 1 or 10M instead.<BR>
       Besides, when you took care for that you won't be mad at me that I didn't add this
       block to the StatsPack reporting (OSPRep), would you?</TD></TR>
  </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
