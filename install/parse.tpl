<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Parsing</TITLE>
</HEAD><BODY>

<H3>Parsing</H3>
<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>A general introduction to this topic already has been described together
  with the <A HREF='parseexec.html'>Parse-to-Execute</A> ratio. Having read
  that, one question has been covered incompletely: How comes the same
  statement is reparsed again and again, though the devs took care for
  bind variables, permissions are fine, and no objects have been altered?
  The answer is quite easy: It has been purged out of the SGAs shared pool
  in between executions.</P>
 <P>There are two special initialization parameters for the handling of
  cursors, which are sometimes messed up in interpretation. First we have
  <CODE>OPEN_CURSORS</CODE>. This parameter defines how many cursors a
  session may keep open simultaneously. The default as defined by Oracle
  is 50 &ndash; while Oracle at the same time recommends to set it to at
  least 500 for most applications. Setting it to a higher value does not
  necessarily mean a waste (so Tom Kyte even recommends setting it to
  1.000). It only means applications <I>may</I> use this much simultaneously
  open cursors, not that they <I>will</I> do so. If you get ORA-1000 errors,
  you may have to increase this parameters value (or take care the application
  closes unused cursors).</P>
 <P>And here we are with the second parameter: <CODE>SESSION_CACHED_CURSORS</CODE>.
  Oracle checks for frequently used cursors and tries to cache them when they
  get closed. If such a cursor is referred to later, it does not need any parse
  (no hard and no soft) if it can be found in this special area (well, we could
  call this "very soft parse"). But only a limited number of cursors can be
  cached (up to your setting of <CODE>SESSION_CACHED_CURSORS</CODE>); if this
  limit is reached, older entries have to be purged from the cursor cache. Which
  is probably what happened to those statements listed in the <I>Top SQL by
  Parse Calls</I> section of the report.</P>

 <H4>Helpful Statistics</H4>
 <P>To give you a raw idea of the effectiveness of your "cursor cache", there
  are some statistics we can query. Let's first try a database wide estimate:
 <PRE CLASS="code">COL parameter FOR A30
SELECT 'session_cached_cursors' parameter,
       TO_NUMBER(value) value,
       100 * used / value usage_in_pct
  FROM (
        SELECT MAX(s.value) used
          FROM v$statname n, v$sesstat s
         WHERE n.name = 'session cursor cache count'
           AND s.statistic# = n.statistic#
       ),
       ( SELECT value FROM v$parameter WHERE name = 'session_cached_cursors' )
UNION ALL
SELECT 'open_cursors',
       TO_NUMBER(value) value,
       100 * used / value usage_in_pct
  FROM (
        SELECT MAX(SUM(s.value)) used
          FROM v$statname n, v$sesstat s
         WHERE n.name IN ('opened cursors current', 'session cursor cache count')
           AND s.statistic# = n.statistic#
         GROUP BY s.sid
       ),
       ( SELECT value FROM v$parameter WHERE name = 'open_cursors' ); </PRE>
 <P>The output will look similar to this:</P>
 <PRE CLASS="code">PARAMETER                           VALUE USAGE_IN_PCT
------------------------------ ---------- ------------
session_cached_cursors                 20          100
open_cursors                          300   33.3333333</PRE>
 <P>In this example, <CODE>SESSION_CACHED_CURSORS</CODE> was set to 20, and
  all of the cache was used. While for the <CODE>OPEN_CURSORS</CODE>, the max
  usage was 1/3 of the upper limit (i.e. no application held more than 100
  cursors open simultaneously). So there is no need to adjust the latter
  parameter, while the former calls for an increase &ndash; if you find some
  statements frequently being reparsed, see the <I>Top SQL by Parse Calls</I>
  statistics.</P>
 <P>Next we take a look into the running sessions, to see how many cursors
  are held open simultaneously by which session:</P>
 <PRE CLASS='code'>COL username FOR A30
SELECT a.username, a.sid, b.value
  FROM v$session a, v$sesstat b, v$statname c
 WHERE b.sid = a.sid
   AND c.statistic# = b.statistic#
   AND c.name = 'opened cursors current'
   AND a.username IS NOT NULL
 ORDER BY 3 desc;</PRE>
 <P>This helps you to determine a decent value for <CODE>OPEN_CURSORS</CODE>
  to prevent ORA-1000 errors: If the "value" of the topmost entries comes
  close to your current setting, it is time to alert the corresponding
  developer (maybe somebody simply forgot to close some unused cursors).
  And as changes in code usually require some time, you may as well want
  to increase the <CODE>OPEN_CURSORS</CODE> setting at least temporarily.</P>
 <P>One more useful statistic will show you which sessions would probably
  profit from an increased <CODE>SESSION_CACHED_CURSORS</CODE> value:</P>
 <PRE CLASS='code'>COL username FOR A30
SELECT s.username, a.sid, a.value parse_cnt,
       (SELECT x.value
          FROM v$sesstat x, v$statname y
         WHERE x.sid = a.sid
           AND y.statistic# = x.statistic#
           AND y.name = 'session cursor cache hits') cache_cnt
  FROM v$session s, v$sesstat a, v$statname b
 WHERE b.statistic# = a.statistic#
   AND s.sid = a.sid
   AND b.name = 'parse count (total)'
   AND value > 0
   AND s.username IS NOT NULL;</PRE>
 <P>In the output generated by this statement, the column <I>CACHE_CNT</I>
  tells you how many times the cache was hit, while <I>PARSE_CNT</I> shows
  how often the statement was called. The closer the values of these
  columns are together, the better. Large discrepancies again show some
  session would profit from an increased <CODE>SESSION_CACHED_CURSORS</CODE>
  value.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OSPRep '+version+' &copy; 2003-2011 by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
