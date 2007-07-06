<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Open Cursor Bug</TITLE>
</HEAD><BODY>

<H3><CODE>STATS$SYSSTAT</CODE> "opened cursors current" can be incorrect!</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P><CODE>V$SYSSTAT</CODE> (and thus also <CODE>STATS$SYSSTAT</CODE> can display a very high
    value for the statistic "opened cursors current" even if the database has only been
    running for a short period of time (eg: 3-4 days). The problem typically occurs when job
    queue processes are being used and either <CODE>RESOURCE_LIMIT</CODE> is set to TRUE or
    the fix for bug 3472564 is installed (see MetaLink note 3926058.8). This affects all
    Oracle versions up to 10.1.0.4 (and is fixed with 10.1.0.5).</P>
 <P>The workaround recommended by MetaLink (taking the correct values from
    <CODE>V$OPEN_CURSOR</CODE>), or the other inoffial workaround (taking them from
    <CODE>V$SESSTAT</CODE>) cannot be used here, since StatsPack does not snap any data from
    those views in levels &lt;= 7. Hence, if you are affected by this bug, and don't want to accept
    the second workaround suggested by MetaLink ("Ignore the value"), you should install the
    <code>get_sesstat()</code> procedure provided by OSPRep (see <code>install/get_sesstat.sql</CODE>)
    and execute it <B><I>after</I></B> each of your <CODE>statspack.snap()</CODE> calls. This
    will collect the information from <code>v$sesstat</code> into the <code>stats$sesstat</code>
    table. If OSPRep finds data here for the first and last snap_id, it will use them instead.
    The column "comment" tells you, where the value for the open cursors is taken from.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
