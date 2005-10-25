<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: LogWriter Statistics</TITLE>
</HEAD><BODY>

<H3>LogWriter Statistics</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>There are some general recommendations to achieve performance of the LGWR
    process:</P>
 <UL>
    <LI>Don't use too small logfiles (Oracles default of often less than
        10MB, depending on the Oracle version, are not even nearly enough
        for most production databases). Good sizes to start with are, depending
        on your session activity, at least 50..100M.</LI>
    <LI>Configure enough log groups. Two groups (which is the minimum allowed
        by Oracle) is only enough for very small databases with almost no activity.
        You should at least have three, better five groups.</LI>
    <LI>Your log buffer should be large enough to allow buffering, but not too
        large. Recommendations differ (of course also depending on database
        size and activity) between 0.5 and (maximum!!) 10 MB. Be aware that the
        value for the <CODE>log_buffer</CODE> parameter is also limited by your
        CPU count (see your Oracle documentation for details).</LI>
 </UL>
 <P>Last but not least, as with almost all database tuning, this task starts with
    SQL Tuning: Your transactions should of course not be too long (so they possibly
    cause a "snapshot too old" error or run into one), but also not too small (i.e.
    don't follow each single <CODE>INSERT</CODE> / <CODE>UPDATE</CODE> /
    <CODE>DELETE</CODE> statement by a <CODE>COMMIT</CODE>).</P>
 <P>The following table gives you additional information to some of the lines in
    the "LogWriter Statistics" block of the report:</P>
  <TABLE ALIGN="center" BORDER="1" WIDTH="99%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Details</TH></TR>
   <TR><TD CLASS="td_name">redo log space requests / h</TD>
       <TD CLASS="inner" STYLE="text-align:justify">This number should be as low as
           possible. When encountering high values here, the reason could be e.g. one of these:<UL>
           <LI>too small log files</LI>
           <LI>not enough redo log groups</LI>
           <LI>too many checkpoints / log file switches (also indicated by high redo wastage,
               see below)</LI></UL></TD></TR>
   <TR><TD CLASS="td_name">redo log space wait time</TD>
       <TD CLASS="inner" STYLE="text-align:justify">Total wait time waiting for completion of
           redo log space requests in 1/10 ms. High values cause <I>log file switch...</I>
           related wait events. If there are many processes waiting for <I>log switch completion</I>,
           it is possible to see <I>log buffer space wait</I> event after log switch is completed.
           Since redo generation is disabled during log switch, there can be high volume of redo
           generation after log switch. This may cause <I>log buffer space wait</I> event.</TD></TR>
   <TR><TD CLASS="td_name">redo log space wait time / redo log space requests</TD>
       <TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">ms/request. If this ratio is
           high, check the followings:<UL>
             <LI>Increase the size of redolog files and/or add new redolog groups</LI>
             <LI>Ensure that log switches occurring not more frequent than around all 20-30 minutes</LI>
           </UL></TD></TR>
   <TR><TD CLASS="td_name">redo wastage percentage</TD>
       <TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">Percentage of redo bytes written
           "unnecessarily" (<I>redo wastage</I> describes the log buffer blocks had been needed to
           be flushed out to disk before they were completely full, which does not mean a problem:
           high values just indicate high LGWR activity). Naturally, this should be very low; if
           it exceeds 20..30% plus you have many log writer wait events, you should check for
           unnecessary checkpoints/log switches.</TD></TR>
   <TR><TD CLASS="td_name">redo synch time / redo synch writes</TD>
       <TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">Milliseconds per write. If this
           ratio is high, check the followings:<UL>
             <LI>A too high <CODE>LOG_BUFFER</CODE> parameter may cause <I>log file sync wait</I>
                 event. This impacts <CODE>COMMIT</CODE> / <CODE>ROLLBACK</CODE> response time,
                 and possibly DBWR performance.</LI>
             <LI>Reduce <CODE>COMMIT</CODE> / <CODE>ROLLBACK</CODE> frequency.</LI>
             <LI>If there are other redolog related wait events, check them (you'll find a list
                 in the "related information" table at the end of the LGWR stats). They may
                 indirectly cause log file sync wait event.</LI>
           </UL></TD></TR>
   <TR><TD CLASS="td_name">redo buffer allocation retries / h</TD>
       <TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">Number of retries per hour
           necessary to allocate space in the redo buffer. Retries are needed either because
           the redo writer has fallen behind or because an event such as a log switch is occurring.</TD></TR>
   <TR><TD CLASS="td_name">redo buffer allocation retries / redo blocks written</TD>
       <TD CLASS="inner" STYLE="text-align:justify" COLSPAN="2">should be less than 0.01 - larger
           values indicate that the LGWR is not keeping up. If this happens, tuning the values for
           <CODE>LOG_CHECKPOINT_INTERVAL</CODE> and <CODE>LOG_CHECKPOINT_TIMEOUT</CODE> (or, with
           Oracle 9i, <CODE>FAST_START_MTTR_TARGET</CODE>) can help to improve the situation.</TD></TR>
  </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2005 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
