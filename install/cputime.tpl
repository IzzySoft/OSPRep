<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Keep in mind that available CPU time depends on the count of available CPUs.
 So if you e.g. have 8 CPUs, each real-time minute corresponds to 8 CPU minutes.
 Knowing this, you will no longer wonder about statements running for e.g. 2min
 using 4min CPU time.</P>
 <P>Now if you encounter high CPU usage, you want to know where it possibly
 origins. The major areas to check for Oracle CPU utilization are:</P>
 <UL>
  <LI>Reparsing SQL statements (check with <I>Total Parses</I> here and with
      the Instance Efficiency Percentages for <I>Soft Parse</I>, <I>Execute to
      Parse</I>, and <I>Parse CPU to Parse Elapsed</I>)</LI>
  <LI>Inefficient SQL statements</LI>
  <LI>Read consistency</LI>
  <LI>Scalability limitations within the application</LI>
  <LI>Latch contention</LI>
 </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
