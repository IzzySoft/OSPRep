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
    <LI>Avoid placing the log files on a slow file system. A RAID-5 system
        is not the best choice for them.</LI>
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
    <CODE>DELETE</CODE> statement by a <CODE>COMMIT</CODE>). You might also
    think of utilizing the <CODE>NOLOGGING</CODE> clause for e.g. direct loads,
    index creation, <CODE>ALTER TABLE .. MOVE|SPLIT</CODE>, <CODE>ALTER INDEX
    SPLIT|REBUILD</CODE>, to minimize unnecessary redo generation.</P>
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
   <TR><TD CLASS="td_name">redo writer latching time</TD>
       <TD CLASS="inner" STYLE="text-align:justify">
           This is the total (cumulative) time LGWR was waiting for flushing
           data from Log Buffer to Redo Log Files. It includes "redo allocation"
           as well as "redo writing" latches.
       </TD></TR>
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
  <P>Below the main table, you find another one containing <I>Related
     Information</I>, which should help you to find causes for possible
     bottle necks. First, they reflect your current configuration, such as
     available redo log groups (including their log file size and number
     of members), and configuration parameters. Here you will further be
     informed of the average number of log file switches per hour (good
     numbers are around 3 to 4).</P>
  <P>Last but not least there is a list of related wait events:</P>
 <TABLE ALIGN="center" BORDER="1" WIDTH="99%" STYLE="margin:5px">
   <TR><TH CLASS="th_sub">WaitEvent</TH><TH CLASS="th_sub">Details</TH></TR>
   <TR><TD CLASS="td_name">log file parallel write</TD>
       <TD CLASS="inner" STYLE="text-align:justify">
        These occur when waiting for writes of REDO records to the REDO
        log files to complete. Even though the writes may be issued in
        parallel, LGWR needs to wait for the last I/O to be on disk before
        the parallel write is considered complete. Log file parallel write
        waits can be reduced by moving log files to the faster disks and/or
        separate disks where there will be less contention.
       </TD></TR>
   <TR><TD CLASS="td_name">log file sync</TD>
       <TD CLASS="inner" STYLE="text-align:justify">
        These are part of the <CODE>COMMIT</CODE> and <CODE>ROLLBACK</CODE>
        procedure. The user session will post the log writer (LGWR) to
        write all REDO information required from the log buffer to the
        REDO log file. When the LGWR has finished, it posts the user
        session. The user session waits on this wait event while waiting
        for LGWR to post it back to confirm all the REDO changes are safely
        on disk.<BR>
        Log file Sync Waits can be reduced by moving log files to the
        faster disks or by reducing <CODE>COMMIT</CODE> frequency by
        performing batch transactions. Do not exaggerate the latter: A too
        low <CODE>COMMIT</CODE> frequency would lead to other problems,
        as it involves locks held and <CODE>UNDO</CODE> space used.
       </TD></TR>
   <TR><TD CLASS="td_name">LGWR wait for redo copy</TD>
       <TD CLASS="inner" STYLE="text-align:justify">
        This usually happens when LGWR was called to flush the log buffers
        to disk, but hit a buffer currently written by another session (i.e.
        the other session holds a <I>redo copy latch</I>). In this case,
        LGWR sleeps for a short time before re-checking whether the buffer
        can be safely accessed (i.e. is no longer occupied by some other
        process).<BR>
        As all this is happening in the background, it should have no negative
        effect on your foreground sessions &ndash; as long as it does not lead
        to <I>log file sync</I> waits (see above).
       </TD></TR>
   <TR><TD CLASS="td_name">log file single write</TD>
       <TD CLASS="inner" STYLE="text-align:justify">
        A wait event occuring while updating the header of the redo log
        files. While contents of each copy of redo log files in the same
        group are identical, the header has differences and thus needs
        a separate update.
       </TD></TR>
  </TABLE>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
