
  PROCEDURE dbwr IS
    pcomment VARCHAR2(2000);
    FUNCTION dbstat(first IN VARCHAR2) RETURN NUMBER IS
      erg NUMBER;
      BEGIN
        SELECT a.val INTO erg
          FROM (
           SELECT decode(e.name,first,e.value) - decode (b.name,first,b.value) val
            FROM stats$sysstat b, stats$sysstat e
           WHERE b.snap_id = BID
             AND e.snap_id = EID
             AND b.dbid    = DB_ID
             AND e.dbid    = DB_ID
             AND b.dbid    = e.dbid
             AND b.instance_number = INST_NUM
             AND e.instance_number = INST_NUM
             AND b.instance_number = e.instance_number
             AND decode(e.name,first,e.value) IS NOT NULL
             AND decode(b.name, first,b.value) IS NOT NULL ) a;
        RETURN erg;
      EXCEPTION
        WHEN OTHERS THEN RETURN '&nbsp;';
      END;
    FUNCTION dbstats(first IN VARCHAR2, last IN VARCHAR2) RETURN NUMBER IS
      erg NUMBER;
      BEGIN
        SELECT a.val / b.val INTO erg
          FROM (
           SELECT decode(e.name,first,e.value) - decode (b.name,first,b.value) val
            FROM stats$sysstat b, stats$sysstat e
           WHERE b.snap_id = BID
             AND e.snap_id = EID
             AND b.dbid    = DB_ID
             AND e.dbid    = DB_ID
             AND b.dbid    = e.dbid
             AND b.instance_number = INST_NUM
             AND e.instance_number = INST_NUM
             AND b.instance_number = e.instance_number
             AND decode(e.name,first,e.value) IS NOT NULL
             AND decode(b.name, first,b.value) IS NOT NULL ) a, (
           SELECT decode(e.name,last,e.value) - decode (b.name,last,b.value) val
            FROM stats$sysstat b, stats$sysstat e
           WHERE b.snap_id = BID
             AND e.snap_id = EID
             AND b.dbid    = DB_ID
             AND e.dbid    = DB_ID
             AND b.dbid    = e.dbid
             AND b.instance_number = INST_NUM
             AND e.instance_number = INST_NUM
             AND b.instance_number = e.instance_number
             AND decode(e.name,last,e.value) IS NOT NULL
             AND decode(b.name, last,b.value) IS NOT NULL ) b
          WHERE b.val > 0;
        RETURN erg;
      EXCEPTION
        WHEN OTHERS THEN RETURN '&nbsp;';
      END;
    FUNCTION numformat (val IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        RETURN to_char(val,'9,999,999,990');
      EXCEPTION
        WHEN OTHERS THEN RETURN NULL;
      END;
    FUNCTION decformat (val IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        RETURN to_char(round(val,2),'9,999,999,990.00');
      EXCEPTION
        WHEN OTHERS THEN RETURN NULL;
      END;
    PROCEDURE write(first IN VARCHAR2, last IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := numformat(dbstats(first,last));
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:22em">'||first||' / '||last||'</TD><TD ALIGN="right">'||
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
               'Number of rollback segment headers written per hour by DBWR. This statistic '||
               'indicates how many "hot" buffers were written, causing a user process to wait '||
               'while the write completed.');
      pcomment := 'Average number of buffers scanned per scan';
      I1 := dbstat('DBWR undo block writes') / (ELA/60);
      writerow('DBWR undo block writes / hour',decformat(I1),
               'Number of rollback segment blocks written per hour by DBWR');
      I1 := dbstat('DBWR revisited being-written buffer') / (ELA/60);
      writerow('DBWR revisited being-written buffer / hour',decformat(I1),
               'Number of times per hour that DBWR tried to save a buffer for writing '||
               'and found that it was already in the write batch. This statistic measures '||
               'the amount of "useless" work that DBWR had to do in trying to fill the batch. '||
               '(If the same buffer from different sources is considered for adding to the write '||
               'batch, then all but the first attempt will be "useless" because the buffer is '||
               'already marked as being written.)');
      write('DBWR buffers scanned','DBWR lru scans',pcomment);
      write('DBWR summed scan depth','DBWR lru scans','Average scan depth');
      write('DBWR free buffers found','DBWR make free requests','Average number of reusable buffers at the end of each LRU');
      pcomment := 'This ratio should be as low as possible. If this value is high, '||
                  'it indicates DBWR is not writing dirty buffers efficiently. High ratio '||
                  'may cause write complete wait wait event.';
      write('dirty buffers inspected','DBWR buffers scanned',pcomment);
      pcomment := 'This ratio should be as low as possible. If this value is high, '||
                  'it indicates high amount of pinned(busy) buffers encountered during '||
                  'free buffer search. This may cause free buffer waits wait event by '||
                  'reducing the possibility of finding free buffer in the LRU list, '||
                  'and then may cause DBWR to perform large batch write to make clean buffers '||
                  'available at the tail of LRU list. This may also increase physical IO if '||
                  'aged out blocks are needed to be re-accessed.<BR>A possible solution is to '||
                  'increase the <CODE>DB_BLOCK_BUFFERS</CODE> (Oracle 8) / '||
                  '<CODE>DB_CACHE_SIZE</CODE> (Oracle 9+).';
      write('pinned buffers inspected','DBWR buffers scanned',pcomment);
      pcomment := 'This ratio shows the average reusable buffers, and should be as high as '||
                  'possible. If it is low, it indicates lack of free space to use. In this '||
                  'case, check the followings:<UL><LI>If dirty buffers inspected is high, '||
                  'it indicates DBWR is not writing dirty buffers efficiently.</LI><LI>'||
                  'If pinned buffers inspected is high, increase <CODE>DB_BLOCK_BUFFERS</CODE> '||
                  '/ <CODE>DB_CACHE_SIZE</CODE>.</LI></UL>';
      write('DBWR free buffers found','DBWR make free requests',pcomment);
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

