<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Undo segment stats</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <H3>Interpretation of the table</H3>
 <TABLE ALIGN="center" WIDTH="95%" BORDER="1">
  <TR><TH CLASS="th_sub">Column</TH><TH CLASS="th_sub">Explanation</TH></TR>
  <TR><TD>Undo Blocks</TD><TD>Represents the total number of undo blocks
      consumed. You can use this column to obtain the consumption rate of undo
      blocks, and thereby estimate the size of the undo tablespace needed to
      handle the workload on your system.</TD></TR>
  <TR><TD># TXN</TD><TD>Identifies the total number of transactions executed
      within the period.</TD></TR>
  <TR><TD>Max Qry Len (s)</TD><TD>Identifies the length of the longest query
      (in number of seconds) executed in the instance during the period. You
      can use this statistic to estimate the proper setting of the
      <CODE>UNDO_RETENTION</CODE> parameter.</TD></TR>
  <TR><TD>Max Tx Concurcy</TD><TD>Identifies the highest number of transactions
      executed concurrently within the period.</TD></TR>
  <TR><TD>Snapshot Too Old</TD><TD>Identifies the number of OER errors
      occurring within a period. You can use this statistic to decide whether
      or not the <CODE>UNDO_RETENTION</CODE> parameter is set properly given
      the size of the undo tablespace. Lowering the <CODE>UNDO_RETENTION</CODE>
      value can reduce the occurrence of this error.</TD></TR>
  <TR><TD>Out of Space</TD><TD>Identifies the number of OER errors reported in
      the current instance. If there is a nonzero value in this column, the
      current undo tablespace needs more space (in the <CODE>UNDO_RETENTION</CODE>
      parameter).</TD></TR>
  <TR><TD>uS</TD><TD>The number of attempts to obtain undo space by stealing
      unexpired extents from other transactions.</TD></TR>
  <TR><TD>uR</TD><TD>The number of unexpired blocks removed from certain undo
      segments so they can be used by other transactions.</TD></TR>
  <TR><TD>uU</TD><TD>The number of unexpired undo blocks reused by transactions.</TD></TR>
  <TR><TD>eS</TD><TD>The number of attempts to steal expired undo blocks from
      other undo segments.</TD></TR>
  <TR><TD>eR</TD><TD>The number of expired undo blocks stolen from other undo
      segments</TD></TR>
  <TR><TD>eU</TD><TD>The number of expired undo blocks reused within the same
      undo segments</TD></TR>
 </TABLE>
</TD></TR></TABLE>

</BODY></HTML>
