
  PROCEDURE topwaits IS
    CURSOR C_Top5 (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, twt IN NUMBER) IS
      SELECT event, waits, time, pctwtt
        FROM ( SELECT e.event event,
                    to_char(e.total_waits - NVL(b.total_waits,0),'9,999,999,999') waits,
		    to_char((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000,'9,999,990.00') time,
		    decode(twt,0,'0.00',
		      to_char(100*((e.time_waited_micro - NVL(b.time_waited_micro,0))/twt),'9,990.00')) pctwtt
                 FROM stats$system_event b, stats$system_event e
	        WHERE b.snap_id(+) = bid
	          AND e.snap_id    = eid
	          AND b.dbid(+)    = db_id
                  AND e.dbid       = db_id
                  AND b.instance_number(+) = instnum
                  AND e.instance_number    = instnum
                  AND b.event(+)   = e.event
                  AND e.event NOT IN ( SELECT event FROM stats$idle_event )
                  ORDER BY time desc, waits desc )
       WHERE rownum <= 5;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="top5wait">Top 5 Wait Events</A></TH></TR>'||CHR(10)||
                ' <TR><TD COLSPAN="4" ALIGN="center">Ordered by Wait Time (desc), Waits (desc)';
      print(L_LINE);
      L_LINE:= '<DIV ALIGN="justify">Start with these topmost events and find out '||
               'about details in the corresponding block, e.g. for "db file * read" '||
               'check the <A HREF="#tsio">TableSpace IO</A> ';
      print(L_LINE);
      L_LINE := '(and <A HREF="#fileio">File IO</A>) blocks to identify the possibly '||
                'affected schemas, and then the <A HREF="#sqlbyreads">SQL Statements '||
                'by Reads</A> (and ';
      print(L_LINE);
      L_LINE := '<A HREF="#waitobjects">Wait Objects</A>) to find out what statements '||
                '(and/or objects) may need some tuning , for "enqueue" waits look '||
                'up the <A HREF="#enq">Enqueue Activity</A> ';
      print(L_LINE);
      L_LINE := 'section of this document. If the CPU is indicated as a bottleneck, '||
                'check the <A HREF="#sqlbygets">SQL Statements by Gets</A>. Then '||
                'continue the same ';
      print(L_LINE);
      L_LINE := 'with the next block, <A HREF="#waitevents">All Wait Events</A></DIV></TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">Wait Time (s)</TH><TH CLASS="th_sub">% Total Wt Time (ms)</TH></TR>';
      print(L_LINE);
      FOR R_Top5 IN C_Top5(DBID,INST_NUM,BID,EID,TWT) LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_Top5.event||'</TD><TD ALIGN="right">'||R_Top5.waits||
                  '</TD><TD ALIGN="right">'||R_Top5.time||'</TD><TD ALIGN="right">'||R_Top5.pctwtt||
	          '</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
