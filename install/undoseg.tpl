<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Undo segment stats</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Interpretation of the table</H3>
 <TABLE ALIGN="center" WIDTH="95%" BORDER="1">
  <TR><TH CLASS="th_sub">Column</TH><TH CLASS="th_sub">Explanation</TH></TR>
  <TR><TD CLASS="td_name">Undo Blocks</TD><TD CLASS="inner" STYLE="text-align:justify">Represents the total number of undo blocks
      consumed. You can use this column to obtain the consumption rate of undo
      blocks, and thereby estimate the size of the undo tablespace needed to
      handle the workload on your system.</TD></TR>
  <TR><TD CLASS="td_name"># TXN</TD><TD CLASS="inner" STYLE="text-align:justify">Identifies the total number of transactions executed
      within the period.</TD></TR>
  <TR><TD CLASS="td_name">Max Qry Len (s)</TD><TD CLASS="inner" STYLE="text-align:justify">Identifies the length of the longest query
      (in number of seconds) executed in the instance during the period. You
      can use this statistic to estimate the proper setting of the
      <CODE>UNDO_RETENTION</CODE> parameter.</TD></TR>
  <TR><TD CLASS="td_name">Max Tx Concurcy</TD><TD CLASS="inner" STYLE="text-align:justify">Identifies the highest number of transactions
      executed concurrently within the period.</TD></TR>
  <TR><TD CLASS="td_name">Snapshot Too Old</TD><TD CLASS="inner" STYLE="text-align:justify">Identifies the number of OER errors
      occurring within a period. You can use this statistic to decide whether
      or not the <CODE>UNDO_RETENTION</CODE> parameter is set properly given
      the size of the undo tablespace. Lowering the <CODE>UNDO_RETENTION</CODE>
      value can reduce the occurrence of this error.</TD></TR>
  <TR><TD CLASS="td_name">Out of Space</TD><TD CLASS="inner" STYLE="text-align:justify">Identifies the number of OER errors reported in
      the current instance. If there is a nonzero value in this column, the
      current undo tablespace needs more space (in the <CODE>UNDO_RETENTION</CODE>
      parameter).</TD></TR>
  <TR><TD CLASS="td_name">uS</TD><TD CLASS="inner" STYLE="text-align:justify">The number of attempts to obtain undo space by stealing
      unexpired extents from other transactions.</TD></TR>
  <TR><TD CLASS="td_name">uR</TD><TD CLASS="inner" STYLE="text-align:justify">The number of unexpired blocks removed from certain undo
      segments so they can be used by other transactions.</TD></TR>
  <TR><TD CLASS="td_name">uU</TD><TD CLASS="inner" STYLE="text-align:justify">The number of unexpired undo blocks reused by transactions.</TD></TR>
  <TR><TD CLASS="td_name">eS</TD><TD CLASS="inner" STYLE="text-align:justify">The number of attempts to steal expired undo blocks from
      other undo segments.</TD></TR>
  <TR><TD CLASS="td_name">eR</TD><TD CLASS="inner" STYLE="text-align:justify">The number of expired undo blocks stolen from other undo
      segments</TD></TR>
  <TR><TD CLASS="td_name">eU</TD><TD CLASS="inner" STYLE="text-align:justify">The number of expired undo blocks reused within the same
      undo segments</TD></TR>
 </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
