  -- Instance Efficiency Percentages
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="efficiency">Instance Efficiency Percentages (Target: 100%)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Efficiency (%)</TH>'||
            '<TH CLASS="th_sub">Comment</TH></TR>';
  print(L_LINE);
  S2 := alert_lt_warn(100*(1-BFWT/GETS),AR_IE_BUFFNW,WR_IE_BUFFNW);
  L_LINE := ' <TR><TD><DIV STYLE="width:13em">Buffer Nowait</DIV></TD><TD ALIGN="right"'||
            S2||'>'||to_char(round(100*(1-BFWT/GETS),2),'990.00');
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">If this ratio is low, check the '||
            '<A HREF="#bufwait">Buffer Wait Stats</A> section for more detail '||
            'on which type of block is being contended for.</TD></TR>';
  print(L_LINE);
  IF RENT = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*(1-BFWT/GETS),2),'990.00');
       S2 := alert_lt_warn(100*(1-BFWT/GETS),AR_IE_REDONW,WR_IE_REDONW);
  END IF;
  L_LINE := ' <TR><TD>Redo Nowait</TD><TD ALIGN="right"'||S2||'>'||S1||
            '</TD><TD CLASS="text">A value close to 100% indicates minimal '||
            'time spent waiting for redo logs ';
  print(L_LINE);
  L_LINE := 'to become available, either because the logs are not filling up '||
            'very often or because the database is able to switch to a new log '||
            'quickly whenever the current log fills up.</TD></TR>';
  print(L_LINE);
  S2 := alert_lt_warn(100*(1-(PHYR-PHYRD-PHYRDL)/GETS),AR_IE_BUFFHIT,WR_IE_BUFFHIT);
  L_LINE := ' <TR><TD>Buffer Hit&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'buffhits'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A>'||
            '</TD><TD ALIGN="right"'||S2||'>'||to_char(round(100*(1-(PHYR-PHYRD-PHYRDL)/GETS),2),'990.00');
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low buffer hit ratio does not necessarily mean '||
            'the cache is too small: it may very well be that potentially valid '||
            'full-table-scans are artificially ';
  print(L_LINE);
  L_LINE := 'reducing what is otherwise a good ratio. A too-small buffer cache '||
            'can sometimes be identified by the appearance of write complete waits '||
            'event indicating hot blocks ';
  print(L_LINE);
  L_LINE := '(i.e. blocks still being modified) are aging out of the cache while '||
            'they are still needed; check the <A HREF="#waitevents">Wait Events</A> '||
            'list for evidence of this event.</TD></TR>';
  print(L_LINE);
  IF (SRTM+SRTD) = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*SRTM/(SRTD+SRTM),2),'990.00');
       S2 := alert_lt_warn(100*SRTM/(SRTD+SRTM),AR_IE_IMSORT,WR_IE_IMSORT);
  END IF;
  L_LINE := ' <TR><TD>In-Memory Sort&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'sorts'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TD>';
  print(L_LINE);
  L_LINE := '<TD ALIGN="right"'||S2||'>'||S1||'</TD><TD CLASS="text">A too low ratio indicates '||
            'too many disk sorts appearing. One possible ';
  print(L_LINE);
  L_LINE := 'solution could be increasing the sort area/SGA size.</TD></TR>';
  print(L_LINE);
  S2 := alert_lt_warn(100*LHTR,AR_IE_LIBHIT,WR_IE_LIBHIT);
  L_LINE := ' <TR><TD>Library Hit</TD><TD ALIGN="right"'||S2||'>'||
            to_char(round(100*LHTR,2),'990.00');
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low library hit ratio could imply that '||
            'SQL is prematurely aging out of a too-small shared pool, or that '||
            'non-shareable SQL is being used. ';
  print(L_LINE);
  L_LINE := 'If the soft parse ratio is also low, check whether there is a '||
            'parsing issue.</TD></TR>';
  print(L_LINE);
  S2 := alert_lt_warn(100*(1-HPRS/PRSE),AR_IE_SOFTPRS,WR_IE_SOFTPRS);
  L_LINE := ' <TR><TD>Soft Parse&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'softparse'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A>'||
            '</TD><TD ALIGN="right"'||S2||'>'||
            to_char(round(100*(1-HPRS/PRSE),2),'990.00')||'</TD><TD CLASS="text">'||
            'When the soft parse ';
  print(L_LINE);
  L_LINE := 'ratio falls much below 80%, investigate whether you can share '||
            'SQL by using bind variables or force cursor sharing. But before '||
            'drawing any conclusions, compare the soft parse ';
  print(L_LINE);
  L_LINE := 'ratio against the actual hard and soft parse rates shown in the '||
            '<A HREF="#loads">Loads Profile</A>. Furthermore, investigate the '||
            'number of <I>Parse CPU to Parse Elapsed</I> below.</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Execute to Parse&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'parseexec'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TD>';
  print(L_LINE);
  L_LINE := '<TD ALIGN="right">'||to_char(round(100*(1-PRSE/EXE),2),'990.00')||
            '</TD><TD CLASS="text">A low value here (&lt; 50%) indicates that there is no '||
            'much re-usable SQL (see <I>Soft Parse</I> for possible actions). ';
  print(L_LINE);
  L_LINE := 'It may also point to a too small shared pool, or frequent logons/logoffs. ';
  print(L_LINE);
  L_LINE := 'Negative values connote that there are more Parses than Executes, '||
            'which could point to syntactically incorrect SQL statements (or '||
            'missing privileges).</TD></TR>';
  print(L_LINE);
  S2 := alert_lt_warn(100*(1-LHR),AR_IE_LAHIT,WR_IE_LAHIT);
  L_LINE := ' <TR><TD>Latch Hit</TD><TD ALIGN="right"'||S2||'>'||
            to_char(round(100*(1-LHR),2),'990.00');
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low value for this ratio indicates a '||
            'latching problem, whereas a high value is generally good. However, '||
            'a high latch hit ratio can artificially mask a low ';
  print(L_LINE);
  L_LINE := 'get rate on a specific latch. Cross-check this value with the '||
            '<A HREF="#top5wait">Top 5 Wait Events</A> to see if latch free is '||
            'in the list, and refer to the ';
  print(L_LINE);
  L_LINE := '<A HREF="#latches">Latch</A> sections of this report.</TD></TR>';
  print(L_LINE);
  IF PRSELA = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*PRSCPU/PRSELA,2),'990.00');
       S3 := alert_lt_warn(100*PRSCPU/PRSELA,AR_IE_PRSC2E,WR_IE_PRSC2E);
  END IF;
  IF TCPU = 0
  THEN S2 := '&nbsp;';
  ELSE S2 := to_char(round(100*(1-(PRSCPU/TCPU)),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Parse CPU to Parse Elapsed</TD><TD ALIGN="right"'||S3||'>'||
            S1||'</TD><TD>A low value here indicates high wait time in parse. '||
            'These will most probably cause shared pool and/or library cache latches.';
  print(L_LINE);
  L_LINE := 'See <I>Soft Parse</I> above.</TD></TR>'||' <TR><TD>Non-Parse CPU</TD>'||
            '<TD ALIGN="right">'||S2||'</TD><TD>A low value here indicates that too much '||
            'time is spent for parsing.';
  print(L_LINE);
  L_LINE := 'See <I>Soft Parse</I> and <I>Execute to Parse</I> above for possible solutions.</TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  print('<HR>');
