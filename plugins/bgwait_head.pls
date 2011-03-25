
  PROCEDURE bgwaits IS
    CURSOR C_BGWait IS
      SELECT e.event event,
             to_char(e.total_waits - NVL(b.total_waits,0),'9,999,999,999') waits,
             to_char(e.total_timeouts - NVL(b.total_timeouts,0),'9,999,999,999') timeouts,
             (e.time_waited_micro - NVL(b.time_waited_micro,0))/1000 time,
             decode ((e.total_waits - NVL(b.total_waits,0)),
                    0,0,
                    ((e.time_waited_micro - NVL(b.time_waited_micro,0))/1000)
                      / (e.total_waits - NVL(b.total_waits,0)) ) wt,
             to_char((e.total_waits - NVL(b.total_waits,0))/TRAN,'99,990.00') txwaits,
             decode(i.event,NULL,0,99) idle,
             decode(i.event,NULL,' ','*') idlemark
        FROM stats$bg_event_summary b, stats$bg_event_summary e, stats$idle_event i
       WHERE b.snap_id(+)  = BID
         AND e.snap_id     = EID
         AND b.dbid(+)     = DB_ID
         AND e.dbid        = DB_ID
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.event(+)    = e.event
         AND e.total_waits > NVL(b.total_waits,0)
         AND i.event(+)    = e.event
       ORDER BY idle, time desc, waits desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="bgwaitevents">Background Wait Events</A></TH></TR>'||CHR(10)||
                ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
                '(desc), Waits (desc); idle events last';
      print(L_LINE);
      L_LINE := '<BR>These are the events waited for by background processes (e.g. '||
                'PMON).<BR>Idle events are marked with an Asterisk*; these do not '||
                'contribute to performance problems.</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time (ms)</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Avg Wait Time (ms)</TH><TH CLASS="th_sub">'||
                'Waits/TXN</TH></TR>';
      print(L_LINE);
      FOR R_BGWait IN C_BGWait LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_BGWait.event||R_BGWait.idlemark||
                  '</TD><TD ALIGN="right">'||R_BGWait.waits||'</TD><TD ALIGN="right">'||
                  R_BGWait.timeouts||'</TD><TD ALIGN="right">'||
                  format_stime(R_BGWait.time,1000)||'</TD><TD ALIGN="right">'||
                  format_stime(R_BGWait.wt,1000)||'</TD><TD ALIGN="right">'||
                  R_BGWait.txwaits||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

