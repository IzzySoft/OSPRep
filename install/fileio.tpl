<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: File IO</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>File I/O and TableSpace I/O</H3>
 <P>If the value for Avg Blks/Rd is higher than 1, this indicates full table
  scans. If it grows higher than <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> we
  must assume that almost every operation on this TS is executed as full table
  scan instead of using an index first, so you should consider creating
  appropriate indices or, maybe, increasing the
  <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE>.</P>
 <P>Note that increasing the <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> may have
  some side effects on the optimizer: it may then prefer a full table scan in
  some cases you may not like it. Having proper indexes on the other side can
  never hurt, so I'ld suggest starting at that point.</P>
 <P>Average Read Times (AvgRd) of greater than 20..40ms should be considered
  slow for single block reads. So if this is the case, you should check whether
  the disks are capable of the required IO rates. If they are, your
  file-to-disk layout may be causing some disks to be underused while others
  are overly busy. Furthermore, if the temporary TableSpaces have the most
  write activity, this may indicate that too much of the sorting is to disk
  and may require optimization.</P>
</TD></TR></TABLE>

</BODY></HTML>
