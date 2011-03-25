
  PROCEDURE lact IS
    t1p VARCHAR2(50); t2p VARCHAR2(50);
    CURSOR C_LAA IS
      SELECT b.name name,
             to_char(e.gets - b.gets,'99,999,999,999') gets,
             DECODE(e.gets,b.gets,'&nbsp;',
                   TO_CHAR((e.misses - b.misses) * 100 /
                          (e.gets - b.gets),'990.00')||'%') missed,
             NVL(to_char(decode(e.misses, b.misses, NULL,
                         (e.sleeps - b.sleeps) / (e.misses - b.misses)),'990.00'),'&nbsp;') sleeps,
             (e.wait_time - b.wait_time)/1000 wt,
             to_char(e.immediate_gets - b.immediate_gets,'99,999,999,999') nowai,
             DECODE(e.immediate_gets, b.immediate_gets,'&nbsp;',
                    TO_CHAR((e.immediate_misses - b.immediate_misses) *100 /
                        (e.immediate_gets - b.immediate_gets),'990.00')||'%')
                imiss
        FROM stats$latch b, stats$latch e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.instance_number = e.instance_number
         AND b.name    = e.name
         AND (  e.gets - b.gets
              + e.immediate_gets - b.immediate_gets ) > 0
       ORDER BY wt DESC,sleeps DESC,imiss DESC;
    CURSOR C_LAS IS
      SELECT b.name name,
             to_char(e.gets - b.gets,'99,999,999,999') gets,
             to_char(e.misses - b.misses,'99,999,999') misses,
             to_char(100*((e.misses - b.misses)/(e.gets - b.gets)),'990.00') pctmiss,
             to_char(e.sleeps - b.sleeps,'999,999,999') sleeps,
             to_char(100*((e.sleeps - b.sleeps)/(e.gets - b.gets)),'990.00') pctsleep,
             to_char(e.spin_gets - b.spin_gets)||'/'||
             to_char(e.sleep1 - b.sleep1)||'/'||
             to_char(e.sleep2 - b.sleep2)||'/'||
             to_char(e.sleep3 - b.sleep3)||'/'||
             to_char(e.sleep4 - b.sleep4) sleep4
        FROM stats$latch b, stats$latch e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.instance_number = e.instance_number
         AND b.name    = e.name
         AND e.sleeps - b.sleeps > 0
       ORDER BY misses desc;
    BEGIN
    -- Latch Activity
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="latches">Latch Activity</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'latches'||CHR(39)||
                ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="7" ALIGN="center">"Get Requests", "Get Miss"'||
                ' and "Avg Slps/Miss" are statistics for willing-to-wait '||
                'latch get requests<BR>"NoWait Requests", "NoWait Miss" are ';
      print(L_LINE);
      L_LINE := 'for no-wait latch get requests<BR>"Misses" for both should be '||
                'very close to 0.0%<BR>Ordered by Wait Time desc, Avg Slps/Miss desc, '||
                'NoWait Miss desc</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Latch</TH><TH CLASS="th_sub">Get Requests</TH>'||
                '<TH CLASS="th_sub">Get Miss</TH><TH CLASS="th_sub">Avg Slps/Miss</TH>'||
                '<TH CLASS="th_sub">Wait Time</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">NoWait Requests</TH><TH CLASS="th_sub">'||
                'NoWait Miss</TH></TR>';
      print(L_LINE);
      FOR R_LA IN C_LAA LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
                  R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.missed||
                  '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||format_stime(R_LA.wt,1000)||'</TD><TD ALIGN="right">'||
                  R_LA.nowai||'</TD><TD ALIGN="right">'||R_LA.imiss||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);

    -- Latch Sleep Breakdown
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7">Latch Sleep Breakdown'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'latches'||CHR(39)||
                ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="7" ALIGN="center">Ordered by Misses desc</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Get Requests</TH>'||
                '<TH CLASS="th_sub">Misses</TH><TH CLASS="th_sub">PctMiss</TH>'||
                '<TH CLASS="th_sub">Sleeps</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">PctSleep</TH><TH CLASS="th_sub">'||
                'Spins &amp; Sleeps 1-&gt;4</TH></TR>';
      print(L_LINE);
      FOR R_LA IN C_LAS LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
                  R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.misses||
                  '</TD><TD ALIGN="right">'||R_LA.pctmiss||'%</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_LA.sleeps||'</TD><TD ALIGN="right">'||
                  R_LA.pctsleep||'%<TD ALIGN="center">'||R_LA.sleep4||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

