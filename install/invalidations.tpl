<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Invalidations of SQL cursors can have different causes:</P>
 <UL>
  <LI>Statistics for dependent objects have been changed
      (<CODE>ANALYZE TABLE/INDEX</CODE>, <CODE>dbms_stats.gather_statistics</CODE>,...)</LI>
  <LI>Definition (DDL) of dependent objects have changed
      (<CODE>ALTER TABLE/INDEX</CODE>, <CODE>COMMENT ON</CODE>,
      <CODE>GRANT/REVOKE</CODE>, <CODE>TRUNCATE TABLE</CODE>,...)</LI>
  <LI>The Shared Pool has been flushed (<CODE>ALTER SYSTEM FLUSH SHARED POOL</CODE>)</LI>
 </UL>
 <P>None of the mentioned actions are typically run frequently on a production
 database - so if a cursor encounters many invalidations, it usually is
 worth some investigation.</P>
</TD></TR></TABLE>

</BODY></HTML>
