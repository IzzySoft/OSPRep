
  PROCEDURE lgwr IS
    pcomment VARCHAR2(2000);
    PROCEDURE writerow(val1 IN VARCHAR2, val2 IN VARCHAR2, val3 IN VARCHAR2) IS
      BEGIN
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:23em">'||val1||'</TD>'||
                  '<TD ALIGN="right" NOWRAP>'||val2||'</TD><TD ALIGN="justify">'||val3||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    PROCEDURE swrite(first IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := numformat( dbstat(first));
        writerow(first,erg,scomment);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    PROCEDURE related IS
      ttime1 DATE; ttime2 DATE;
      CURSOR lgi IS
       SELECT group#,bytes,members FROM v$log;
      PROCEDURE printwait(event IN VARCHAR2) IS
       BEGIN
         get_wait(event,S1,S2,S3,S4);
         L_LINE := '  <TR><TD>'||event||'</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||
                   S3||'</TD><TD ALIGN="right">'||S1||'</TD><TD ALIGN="right">'||S4||'</TD></TR>';
         print(L_LINE);
       EXCEPTION
        WHEN OTHERS THEN NULL;
       END;
      BEGIN
        L_LINE := ' <TR><TD COLSPAN="3"><BR>'||TABLE_OPEN||
                  '  <TR><TH CLASS="th_sub" COLSPAN="3">Related Information</TH></TR>'||
                  CHR(10)||'  <TR><TD>'||TABLE_OPEN||CHR(10)||
                  '  <TR><TH CLASS="th_sub2">Parameter</TH><TH CLASS="th_sub2">Value</TH></TR>';
        print(L_LINE);
        I1 := to_number( parameter('log_checkpoint_interval'),'999999999');
        print(' <TR><TD>log_checkpoint_interval</TD><TD ALIGN="right">'||numformat(I1)||'</TD></TR>');
        I1 := to_number( parameter('log_checkpoint_timeout'),'999999999');
        print(' <TR><TD>log_checkpoint_timeout</TD><TD ALIGN="right">'||numformat(I1)||'</TD></TR>');
        I1 := to_number( parameter('log_checkpoint_mttr_target'),'999999999');
        S1 := NVL(numformat(I1),'&nbsp;');
        print(' <TR><TD>log_checkpoint_mttr_target</TD><TD ALIGN="right">'||S1||'</TD></TR>');
        I1 := to_number( parameter('log_buffer'),'999999999');
        print(' <TR><TD>log_buffer</TD><TD ALIGN="right">'||format_fsize(I1)||'</TD></TR>');
        SELECT startup_time INTO ttime2 FROM v$instance;
        SELECT MIN(completion_time) INTO ttime1 FROM v$archived_log
         WHERE completion_time > ttime2;
        IF ttime1 IS NOT NULL THEN
          SELECT MAX(completion_time) INTO ttime2 FROM v$archived_log;
          SELECT COUNT(sequence#) INTO I1 FROM v$archived_log
           WHERE completion_time BETWEEN ttime1 AND ttime2;
          I2 := (ttime2 - ttime1)*24;
          print(' <TR><TD>avg. log switches / h</TD><TD ALIGN="right">'||decformat(I1/I2)||'</TD></TR>');
        END IF;
        L_LINE := ' </TABLE></TD><TD>'||TABLE_OPEN||'  <TR><TH CLASS="th_sub2" COLSPAN="3">'||
                  'Redo Log Groups</TH></TR>'||CHR(10)||'  <TR><TH CLASS="th_sub2">#</TH>'||
                  '<TH CLASS="th_sub2">Members</TH><TH CLASS="th_sub2">Size</TH></TR>';
        print(L_LINE);
        FOR lg IN lgi LOOP
          L_LINE := '  <TR><TD ALIGN="right">'||lg.group#||'</TD><TD ALIGN="right">'||
                    lg.members||'</TD><TD ALIGN="right">'||format_fsize(lg.bytes)||'</TD></TR>';
          print(L_LINE);
        END LOOP;
        L_LINE := '</TABLE></TD><TD>'||TABLE_OPEN||'  <TR><TH CLASS="th_sub2">WaitEvent</TH>'||
                  '<TH CLASS="th_sub2">Waits</TH><TH CLASS="th_sub2">WaitTime</TH>'||
                  '<TH CLASS="th_sub2">AvgWaitTime</TH><TH CLASS="th_sub2">Timeouts</TH></TR>';
        print(L_LINE);
        printwait('LGWR wait for redo copy');
        printwait('log file switch (checkpoint incomplete)');
        printwait('log file switch (archiving needed)');
        printwait('log file switch completion');
        printwait('log file parallel write');
        printwait('log file single write');
        printwait('log buffer wait');
        printwait('log buffer space');
        print('</TABLE></TD></TR>');
        print('</TABLE></TD></TR>');
      EXCEPTION
        WHEN OTHERS THEN print('</TD></TR></TABLE>');
      END;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="lgwr"></A>Log Writer Statistics&nbsp;<A '||
                'HREF="JavaScript:popup('||CHR(39)||'lgwr'||CHR(39)||')"><IMG SRC="help/help.gif" '||
                'BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Value</TH>'||
                '<TH CLASS="th_sub">Comment</TH></TR>';
      print(L_LINE);
      pcomment := 'The active logfile had been full, and Oracle had waited for disk space to '||
                  'be allocated for the redolog entries by performing log switches. High values '||
                  'indicate high amount of log switches.';
      swrite('redo log space requests',pcomment);
      I1 := round ( dbstat('redo log space requests') / (ELA/3600),2 );
      S1 := to_char(I1,'9,990.00');
      writerow('redo log space requests / h',S1,'This number should be as low as possible.</LI></UL>');
      pcomment := 'Total wait time waiting for completion of redo log space requests in 1/10 ms.';
      swrite('redo log space wait time',pcomment);
      I2 := dbstat('redo log space requests');
      IF I2 > 0 THEN
        I1 := round ( (dbstat('redo log space wait time')/10) / I2, 2);
      ELSE
        I1 := 0;
      END IF;
      S1 := to_char(I1,'9,990.00');
      writerow('redo log space wait time / redo log space requests',S1,'ms/request. Should be as low as possible.');
      pcomment := 'Percentage of redo bytes written "unnecessarily". Naturally, this should be very low.';
      I2 := dbstat('redo wastage');
      I1 := round( I2 * 100 / (dbstat('redo size') + I2),2);
      S1 := to_char(I1,'9,990.00');
      S2 := alert_gt_warn(I1,AR_RWP,WR_RWP);
      L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:22em">redo wastage percentage</TD>'||
                '<TD ALIGN="right"'||S2||'>'||S1||'%</TD><TD ALIGN="justify">'||pcomment||'</TD></TR>';
      print(L_LINE);
      pcomment := 'Changes to redolog buffer had been flushed out to disk immediately such as '||
                  '<code>COMMIT</code> / <code>ROLLBACK</code>.';
      swrite('redo synch writes',pcomment);
      pcomment := 'Elapsed time of all redo synch writes in 1/10 ms. High values cause '||
                  '<i>log file sync</i> wait event.';
      swrite('redo synch time',pcomment);
      pcomment := 'Milliseconds per write. This value should be low.';
      I1 := round( (dbstat('redo synch time') / 10) * 1000 / dbstat('redo synch writes'), 2 );
      S1 := to_char(I1,'9,990.00');
      writerow('redo synch time / redo synch writes',S1,pcomment);
      pcomment := 'Number of retries per hour necessary to allocate space in the redo buffer. '||
                  'Should be very low.';
      I1 := dbstat('redo buffer allocation retries') / (ELA/3600);
      S1 := to_char(I1,'9,990.00');
      writerow('redo buffer allocation retries / h',S1,pcomment);
      I1 := dbstats('redo buffer allocation retries','redo blocks written');
      writerow('redo buffer allocation retries / redo blocks written',decformat(I1),
               'should be less than 0.01 - larger values indicate that the LGWR is not keeping up. '||
               'If this happens, tuning the values for <code>LOG_CHECKPOINT_INTERVAL</code> and '||
               '<code>LOG_CHECKPOINT_TIMEOUT</code> (or, with Oracle 9i, '||
               '<code>FAST_START_MTTR_TARGET</code>) can help to improve the situation.');
      S1 := decformat(dbstats('redo blocks written','redo writes'));
      writerow('redo blocks written / redo writes',S1,'Number of blocks per write');
      I1 := dbstat('redo size') / (ELA/60);
      S1 := format_fsize(I1)||'/min';
      writerow('redo emergence',S1,'How much redo information is written on average '||
               'during the snapshot interval given.');
      I1 := dbstat('redo write time') /(10*1000);
      I2 := round(I1 * 100 / ELA,2);
      S2 := decformat(I2)||'%';
      writerow('redo time used',S2,'Rate of time spent for writing redo information '||
               'during the snapshot interval given. This value should be close to 0%.');
      I1 := dbstat('redo size');
      S1 := format_fsize(I1);
      writerow('redo size',S1,'Total amount of redo generated');
      related();
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

