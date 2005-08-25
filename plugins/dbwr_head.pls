
  PROCEDURE dbwr IS
    pcomment VARCHAR2(2000);
    FUNCTION dbstats(first IN VARCHAR2, last IN VARCHAR2) RETURN VARCHAR2 IS
      erg VARCHAR2(20);
      BEGIN
        SELECT to_char( a.val / b.val, '9,999,999,990') INTO erg
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
    PROCEDURE write(first IN VARCHAR2, last IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := dbstats(first,last);
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:22em">'||first||' / '||last||'</TD><TD ALIGN="right">'||
                  erg||'</TD><TD ALIGN="justify">'||scomment||'</TD></TR>';
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
      pcomment := 'Average number of buffers scanned per scan';
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

