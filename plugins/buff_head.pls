
  PROCEDURE spstat IS
    CURSOR C_SPSQL IS
      SELECT (100*(1-b.single_use_sql/b.total_sql)) AS b_single_sql,
             (100*(1-e.single_use_sql/e.total_sql)) AS e_single_sql,
             (100*(1-b.single_use_sql_mem/b.total_sql_mem)) AS b_single_mem,
             (100*(1-e.single_use_sql_mem/e.total_sql_mem)) AS e_single_mem
        FROM stats$sql_statistics b, stats$sql_statistics e
       WHERE b.snap_id=BID
         AND e.snap_id=EID
         AND b.instance_number=INST_NUM
         AND e.instance_number=INST_NUM
         AND b.dbid=DB_ID
         AND e.dbid=DB_ID;

    PROCEDURE poolsize(aval IN VARCHAR2, bval OUT VARCHAR2, eval OUT VARCHAR2) IS
      BEGIN
        SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
              0,DECODE(SIGN(LENGTH(ROUND(value/1000))-1),
                0,to_char(nvl(value,0)/1024,'999,999,990.00')||' K',
                to_char(nvl(value,0)/1024/1024,'999,999,990.00')||' M'),
              1,value,'&nbsp;')
          INTO bval
          FROM stats$parameter
         WHERE name=aval
           AND snap_id=BID
           AND instance_number=INST_NUM
           AND dbid=DB_ID;
        SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
                  0,DECODE(SIGN(LENGTH(ROUND(value/1000))-1),
                      0,to_char(nvl(value,0)/1024,'999,999,990.00')||' K',
                      to_char(nvl(value,0)/1024/1024,'999,999,990.00')||' M'),
                  1,value,'&nbsp;')
          INTO eval
          FROM stats$parameter
         WHERE name=aval
           AND snap_id=EID
           AND instance_number=INST_NUM
           AND dbid=DB_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;

    BEGIN
    -- Pool Sizes
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sharedpool">Pool Sizes</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'poolsize'||CHR(39)||
                ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A>';
      print(L_LINE);
      L_LINE := '</TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Begin</TH><TH CLASS="th_sub">End</TH></TR>';
      print(L_LINE);
      poolsize('shared_pool_size',S1,S2);
      L_LINE := ' <TR><TD>Shared_Pool_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      poolsize('shared_pool_reserved_size',S1,S2);
      L_LINE := L_LINE||' <TR><TD>Shared_Pool_Reserved_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      print(L_LINE);
      poolsize('large_pool_size',S1,S2);
      L_LINE := ' <TR><TD>Large_Pool_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      poolsize('java_pool_size',S1,S2);
      L_LINE := L_LINE||' <TR><TD>Java_Pool_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      print(L_LINE);
      poolsize('sort_area_size',S1,S2);
      L_LINE := ' <TR><TD>Sort_Area_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      poolsize('sort_area_retained_size',S1,S2);
      L_LINE := L_LINE||' <TR><TD>Sort_Area_Retained_Size</TD><TD ALIGN="right">'||NVL(S1,'&nbsp;')||'</TD>'||
                '<TD ALIGN="right">'||NVL(S2,'&nbsp;')||'</TD></TR>'||CHR(10);
      print(L_LINE);
      print(TABLE_CLOSE);

    -- Shared Pool Stats
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3">Shared Pool Statistics</TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Begin</TH>'||
                '<TH CLASS="th_sub">End</TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="td_name">Memory Usage %</TD><TD>'||
                to_char(round(100*(1-BFRM/BSPM),2),'990.00')||'</TD><TD>'||
                to_char(round(100*(1-EFRM/ESPM),2),'990.00')||'</TD></TR>';
      print(L_LINE);
      FOR R_SPSQL IN C_SPSQL LOOP
        L_LINE := ' <TR><TD CLASS="td_name">% SQL with executions &gt; 1</TD><TD>'||
                  to_char(round(R_SPSQL.b_single_sql,2),'990.00')||'</TD><TD>'||
                  to_char(round(R_SPSQL.e_single_sql,2),'990.00')||'</TD></TR>';
        print(L_LINE);
        L_LINE := ' <TR><TD CLASS="td_name">% Memory for SQL with executions &gt; 1</TD><TD>'||
                  to_char(round(R_SPSQL.b_single_mem,2),'990.00')||'</TD><TD>'||
                  to_char(round(R_SPSQL.e_single_mem,2),'990.00')||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE buffp IS
    ratz VARCHAR2(20);
    CURSOR C_BuffP IS
      SELECT replace(e.block_size/1024||'k',BS/1024||'k',substr(e.name,1,1)) name,
             e.set_msize numbufs,
             nvl(to_char(decode( e.db_block_gets   - nvl(b.db_block_gets,0) + e.consistent_gets - nvl(b.consistent_gets,0),
                                 0, to_number(NULL),
                                 (100* (1- (  (e.physical_reads  - nvl(b.physical_reads,0)) / (  e.db_block_gets   - nvl(b.db_block_gets,0)
                                   + e.consistent_gets - nvl(b.consistent_gets,0))
                                   ) ) )
                        ),'990.9' ),'&nbsp;') hitratio,
             to_char(  e.db_block_gets   - nvl(b.db_block_gets,0)
               + e.consistent_gets - nvl(b.consistent_gets,0), '99,999,999,999') gets,
             to_char(e.physical_reads - nvl(b.physical_reads,0), '99,999,999,999') phread,
             to_char(e.physical_writes - nvl(b.physical_writes,0), '999,999,999') phwrite,
             to_char(e.free_buffer_wait - nvl(b.free_buffer_wait,0), '999,999') fbwait,
             to_char(e.write_complete_wait - nvl(b.write_complete_wait,0), '999,999') wcwait,
             to_char(e.buffer_busy_wait - nvl(b.buffer_busy_wait,0), '999,999,999') bbwait,
             (((e.consistent_gets - b.consistent_gets) + (e.db_block_gets - b.db_block_gets)) -
                 (e.physical_reads - b.physical_reads)) ratio_top,
             ((e.consistent_gets - b.consistent_gets) +
                 (e.db_block_gets - b.db_block_gets)) ratio_but
        FROM stats$buffer_pool_statistics b, stats$buffer_pool_statistics e
       WHERE b.snap_id(+)  = BID
         AND e.snap_id     = EID
         AND b.dbid(+)     = DB_ID
         AND e.dbid        = DB_ID
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.id(+)       = e.id
       ORDER BY e.name;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10">Buffer Pool Statistics</TH></TR>'||
                ' <TR><TD COLSPAN="10" ALIGN="center">Standard Block Size Pools ';
      print(L_LINE);
      L_LINE := 'D:Default, K:Keep, R:Recycle<BR>Default Pools for other block '||
                'sizes: 2k, 4k, 8k, 16k, 32k</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub"># of Buffers</TH>'||
                '<TH CLASS="th_sub">Cache Hit %</TH><TH CLASS="th_sub">Buffer Gets</TH>'||
                '<TH CLASS="th_sub">PhyReads</TH>';
      print(L_LINE);
      L_LINE:= '<TH CLASS="th_sub">PhyWrites</TH><TH CLASS="th_sub">FreeBuf Waits</TH>'||
               '<TH CLASS="th_sub">Wrt complete Waits</TH><TH CLASS="th_sub">Buffer Busy Waits</TH>'||
               '<TH CLASS="th_sub">HitRatio (%)</TH></TR>';
      print(L_LINE);
      FOR R_Buff IN C_BuffP LOOP
        IF R_Buff.ratio_but > 0 THEN
          ratz := to_char(100*R_Buff.ratio_top / R_Buff.ratio_but,'990.00');
        ELSE
          ratz := '&nbsp;';
        END IF;
        L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.name||'</TD><TD ALIGN="right">'||
                  R_Buff.numbufs||'</TD><TD ALIGN="right">'||
                  R_Buff.hitratio||'</TD><TD ALIGN="right">'||R_Buff.gets||
                  '</TD><TD ALIGN="right">'||R_Buff.phread||'</TD><TD ALIGN="right">';
        print(L_LINE);
        L_LINE := R_Buff.phwrite||'</TD><TD ALIGN="right">'||R_Buff.fbwait||
                  '</TD><TD ALIGN="right">'||R_Buff.wcwait||'</TD><TD ALIGN="right">'||
                  R_Buff.bbwait||'</TD><TD ALIGN="right">'||ratz||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE buffw IS
    CURSOR C_BuffW IS
      SELECT e.class class,
             to_char(e.wait_count - nvl(b.wait_count,0),'999,999,999,999') icnt,
             (e.time - nvl(b.time,0))/100 itim,
             (e.time - nvl(b.time,0)) /
               (e.wait_count - nvl(b.wait_count,0)) * 10 iavg,
             TO_CHAR(DECODE((e.time - nvl(b.time,0))/100,0,NULL,
                 (e.wait_count - nvl(b.wait_count,0))/((e.time - nvl(b.time,0))/100)),
                  '999,990.00') wps
        FROM stats$waitstat b, stats$waitstat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.instance_number = e.instance_number
         AND b.class   = e.class
         AND b.wait_count < e.wait_count
       ORDER BY itim desc, icnt desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Buffer Wait Statistics'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'buffwaits'||CHR(39)||
                ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      print(' <TR><TD COLSPAN="5" ALIGN="center">Ordered by Wait Time desc, Waits desc</TD></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">Class</TH><TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">Tot Wait Time</TH>'||
                '<TH CLASS="th_sub">Avg Wait Time</TH>'||
                '<TH CLASS="th_sub">Waits/s</TH></TR>';
      print(L_LINE);
      FOR R_Buff IN C_BuffW LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.class||'</TD><TD ALIGN="right">'||
                  R_Buff.icnt||'</TD><TD ALIGN="right">'||format_stime(R_Buff.itim,1)||
                  '</TD><TD ALIGN="right">'||format_stime(R_Buff.iavg,1);
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right">'||NVL(R_Buff.wps,'&nbsp;')||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
