
  PROCEDURE dbwr IS
    pcomment VARCHAR2(2000);
    PROCEDURE write(first IN VARCHAR2, last IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := decformat(dbstats(first,last));
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:23em">'||first||' / '||last||'</TD><TD ALIGN="right">'||
                  erg||'</TD><TD ALIGN="justify">'||scomment||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    PROCEDURE writerow(val1 IN VARCHAR2, val2 IN VARCHAR2, val3 IN VARCHAR2) IS
      BEGIN
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:22em">'||val1||'</TD>'||
                  '<TD ALIGN="right">'||val2||'</TD><TD ALIGN="justify">'||val3||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="dbwr"></A>Database Writer Statistics&nbsp;'||
                '<A HREF="JavaScript:popup('||CHR(39)||'dbwr'||CHR(39)||
                ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Value</TH>'||
                '<TH CLASS="th_sub">Comment</TH></TR>';
      print(L_LINE);
      I1 := dbstat('DBWR checkpoint buffers written') / (ELA/60);
      writerow('DBWR checkpoint buffers written / hour',decformat(I1),
               'Number of buffers written per hour for checkpoints');
      I1 := dbstat('DBWR transaction table writes') / (ELA/60);
      writerow('DBWR transaction table writes / hour',decformat(I1),
               'Number of rollback segment headers written per hour by DBWR.');
      pcomment := 'Average number of buffers scanned per scan';
      I1 := dbstat('DBWR undo block writes') / (ELA/60);
      writerow('DBWR undo block writes / hour',decformat(I1),
               'Number of rollback segment blocks written per hour by DBWR');
      I1 := dbstat('DBWR revisited being-written buffer') / (ELA/60);
      writerow('DBWR revisited being-written buffer / hour',decformat(I1),
               'How often DBWR tried to save a buffer and found it already in the write batch.');
      write('DBWR buffers scanned','DBWR lru scans',pcomment);
      write('DBWR summed scan depth','DBWR lru scans','Average scan depth');
      write('free buffer inspected','free buffer requested',
            'If this value is to high, you may need to increase your buffer cache.');
      pcomment := 'This ratio should be as low as possible. If this value is high, '||
                  'it indicates DBWR is not writing dirty buffers efficiently. High ratio '||
                  'may cause write complete wait wait event.';
      write('dirty buffers inspected','DBWR buffers scanned',pcomment);
      pcomment := 'This ratio should be as low as possible.';
      write('pinned buffers inspected','DBWR buffers scanned',pcomment);
      pcomment := 'This ratio shows the average reusable buffers, and should be as high as possible.';
      write('DBWR free buffers found','DBWR make free requests',pcomment);
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

