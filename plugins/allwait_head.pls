
  PROCEDURE allwaits IS
    CURSOR C_AllWait IS
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
        FROM stats$system_event b, stats$system_event e, stats$idle_event i
       WHERE b.snap_id(+)  = BID
         AND e.snap_id     = EID
         AND b.dbid(+)     = DB_ID
         AND e.dbid        = DB_ID
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.event(+)    = e.event
         AND e.total_waits > NVL(b.total_waits,0)
         AND e.event NOT LIKE '%timer%'
         AND e.event NOT LIKE 'rdbms ipc%'
         AND i.event(+)    = e.event
       ORDER BY idle, time desc, waits desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="waitevents">All Wait Events</A></TH></TR>'||CHR(10)||
                ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
	        '(desc), Waits (desc); idle events last<BR>';
      print(L_LINE);
      L_LINE := 'All events waited for by foreground (server) processes.<BR>'||
                'Idle events are marked with an Asterisk*; these do not '||
	        'contribute to performance problems.</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	        '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Avg Wait Time</TH><TH CLASS="th_sub">'||
                'Waits/TXN</TH></TR>';
      print(L_LINE);
      FOR R_AllWait IN C_AllWait LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_AllWait.event||R_AllWait.idlemark||
                  '</TD><TD ALIGN="right">'||R_AllWait.waits||'</TD><TD ALIGN="right">'||
	          R_AllWait.timeouts||'</TD><TD ALIGN="right">'||
	          format_stime(R_AllWait.time,1000)||'</TD><TD ALIGN="right">'||
                  format_stime(R_AllWait.wt,1000)||'</TD><TD ALIGN="right">'||
	          R_AllWait.txwaits||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

