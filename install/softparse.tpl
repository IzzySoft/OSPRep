<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Soft Parse</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>A soft parse occurs when a session attempts to execute a SQL statement and
  a usable version of the statement is already in the shared pool, so the
  statement can be executed immediately. The hard parse is the opposite and an
  expensive operation. When the soft parse ratio falls much below 80%,
  investigate whether you can share SQL by using bind variables or force cursor
  sharing by using the init.ora parameter cursor_sharing (new in Oracle8i
  Release 8.1.6).</P>
 <P>But before drawing any conclusions, compare the soft parse ratio against
  the actual hard and soft parse rates shown in the Loads Profile. If the rates
  are low, parsing may not be a significiant issue in your system. Furthermore,
  investigate the number of Parse CPU to Parse Elapsed below. If this value is
  low, you may rather have a latch problem.</P>
</TD></TR></TABLE>

</BODY></HTML>
