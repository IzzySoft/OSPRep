<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
  <P>The abbreviation <I>ITL</I> stands for <B>I</B>nterested <B>T</B>ransaction
     <B>L</B>ist. <I>ITL waits</I> are connected with the Oracle locking mechanism.
     You can think of the <I>ITL</I> as a kind of subscription list: A transaction
     wants to update a table row. To prevent collision with other transactions, the
     corresponding row has to be locked &ndash; which is done in the header of its
     block. So when another transaction wants to lock the same row, it finds
     "number one" had signed its interest first: the row in question is already
     locked.</P>
  <P>However, the number of ITL slots per block is somehow limited. If there's no
     free slot left, even if the requested row is not locked, the transaction
     can not sign its interest (i.e. place a lock on the row it wants to change),
     but has to wait for an ITL slot to be freed (which will happen as soon as
     some other involved transaction does its <CODE>COMMIT</CODE> or
     <CODE>ROLLBACK</CODE>) &ndash; we have an <I>ITL wait</I>. The same happens
     even when the maximum number of ITL slots was not assigned, but the block
     header has no space left for another slot.</P>
  <P>So what can you do here? If there is a segment/table shown with a high
     number of ITL waits, you could consider...</P><UL>
     <LI>...playing with the <A HREF="initrans.html"><CODE>INITRANS</CODE> or
         <CODE>MAXTRANS</CODE></A> values for the affected table</LI>
     <LI>...increase <CODE>PCTFREE</CODE> for the table in question. This
         may help since the ITL is maintained in the variable size header
         (which grows top-down until it meets the data growing button-up;
         so if you stop the latter a bit earlier, chances are more ITL slots
         fit in)</LI>
     <LI>...think of increasing <CODE>FREELISTS</CODE> and <CODE>FREELIST
         GROUPS</CODE> for this table (usually only with 9i and earlier)</LI>
     <LI>...consider enabling ASSM (Automatic Segment Space Management)
         for the tablespace in question (starting with Oracle 10g, this is
         done by default; with 9i you can optionally enable it. Versions
         prior to 9i do not offer ASSM). This at least frees you from dealing
         with freelists and freelist groups &ndash; but you still have to
         look out for the ITL stuff.</LI>
  </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
