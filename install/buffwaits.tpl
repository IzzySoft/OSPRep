<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>If Waits/s are high for a given class, you may consider some tuning: For
  the undo headers/blocks, adding more rollback segments can help. With data
  blocks, increasing the size of the database buffer cache can reduce these
  waits. Segment header waits generally point to the need to add freelists to
  the affected table. Freelist block waits indicate that the affected segment
  needs a higher number of freelists - for the Oracle Parallel Server, make
  sure each instance has its own freelist groups.</P>
</TD></TR></TABLE>

</BODY></HTML>
