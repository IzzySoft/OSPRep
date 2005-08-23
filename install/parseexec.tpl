<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Parse/Execute</TITLE>
</HEAD><BODY>

<H3>Parse-to-execute-Ratio</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Since parsing is an expensive operation, the goal should be to keep its count
 as low as possible. Best is to parse once and execute many. But what does this
 mean? If you have a high parse ratio, you might want to discover its reason. For
 this first have a look at what parsing means. Parsing includes the following steps:</P>
 <OL><LI>Make a syntax check on the SQL statement</LI>
     <LI>Make a semantic check (i.e. check that the refered tables, views, etc. exist)</LI>
     <LI>Make a security check (i.e. look that the "executer" has permission on the refered objects)</LI>
     <LI>Generate an execution plan</LI></OL>
 <P>Thus if a parse call fails (which is likely to be the case if you have more parses than
 executes), this can be due to 3 different reasons:</P>
 <UL><LI>Syntax errors in your SQL statement(s)</LI>
     <LI>Refering to not existing (or invalid) objects</LI>
     <LI>Missing <code>GRANT</code>s</LI></UL>
 <P>What else can lead to unnecessary parsing? For this the question is first what time a parse
 is needed to be done. If Oracle successfully completes parsing, the statement will be stored to
 the SQLArea, together with its execution plan. So if we call the same statement again, it will
 be found in this "cache", the parsing step can be skipped, and we can go straight to execute the
 statement. But what is recognized to be the same statement? It must be the exact same spelling
 (even case makes a difference!), so <code>select sysdate from dual;</code> and <code>SELECT
 sysdate FROM dual;</code> are two different statements. And of course, including a <code>WHERE</code>
 clause makes a difference if you write <code>WHERE sample=5</code> and in the next statement
 <code>WHERE sample=7</code>. For this, you should make use of bind variables: <code>WHERE sample=:B1</code>
 does not need to be parsed again even if you substitute a different value for :B1.</P>
 <P>One more thing that may unnecessarily increase parsing is an application that frequently
 discards cursors. If you have no influence on the application, it may be helpful to create a "cursor
 cache" in your database. For this issue, you may use the <code>SESSION_CACHED_CURSORS</code>
 parameter. You also may want to have a look at the <A HREF="softparse.html">soft parse</A> issue to
 seehow the <code>CURSOR_SHARING</code> parameter may be helpful.</P>
 <P>Another hint is to use stored procedures whenever it is possible. Multiple users issuing the
 same stored code use the same shared PL/SQL area automatically. Because stored procedures are stored
 in a parsed form, their use reduces runtime parsing.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
