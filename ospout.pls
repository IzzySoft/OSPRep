  -- SnapShot Info
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="snapinfo">SnapShot Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Snap ID</TH>';
  print(L_LINE);
  L_LINE := ' <TH CLASS="th_sub">Snap Time</TH><TH CLASS="th_sub">Sessions</TH>'||
            '<TH CLASS="th_sub">Curs/Sess</TH><TH CLASS="th_sub">Comment</TH></TR>';
  print(L_LINE);
  FOR Rec_SnapInfo IN C_SnapInfo(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD>Start</TD><TD ALIGN="right">'||Rec_SnapInfo.begin_snap_id||'</TD><TD>'||
              Rec_SnapInfo.begin_snap_time||'</TD><TD ALIGN="right">'||BLOG||'</TD><TD ALIGN="right">'||
	      to_char(BOCUR/BLOG,'9,990.00')||'<TD>'||Rec_SnapInfo.begin_snap_comment||'</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD>End</TD><TD ALIGN="right">'||Rec_SnapInfo.end_snap_id||'</TD><TD>'||
              Rec_SnapInfo.end_snap_time||'</TD><TD ALIGN="right">'||ELOG||'</TD><TD ALIGN="right">'||
	      to_char(EOCUR/ELOG,'9,990.00')||'<TD>'||Rec_SnapInfo.end_snap_comment||'</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="6" ALIGN="center">Elapsed: '||Rec_SnapInfo.elapsed||
              ' min</TD></TR>';
    print(L_LINE);
    ELA  := Rec_SnapInfo.ela;
    EBGT := Rec_SnapInfo.ebgt;
    EDRT := Rec_SnapInfo.edrt;
    EET  := Rec_SnapInfo.eet;
    EPC  := Rec_SnapInfo.epc;
    BTIME:= Rec_SnapInfo.begin_snap_time;
    ETIME:= Rec_SnapInfo.end_snap_time;
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Cache Sizes
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="cachesizes">Cache Sizes (End)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Size</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Buffer Cache</TD><TD ALIGN="right">'||to_char(round(BC/1024/1024),'999,999')||' M</TD></TR>'||
            ' <TR><TD>Std Block Size</TD><TD ALIGN="right">'||to_char(round(BS/1024),'999,999')||' K</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Shared Pool Size</TD><TD ALIGN="right">'||to_char(round(SP/1024/1024),'999,999')||' M</TD></TR>'||
            ' <TR><TD>Log Buffer</TD><TD ALIGN="right">'||to_char(round(LB/1024),'999,999')||' K</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Load Profile
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="loads">Load Profile</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Per Second</TH><TH CLASS="th_sub">Per Transaction</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Redo Size</TD><TD ALIGN="right">'||
            to_char(round(RSIZ/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(RSIZ/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Logical Reads</TD><TD ALIGN="right">'||
            to_char(round(GETS/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(GETS/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Block Changes</TD><TD ALIGN="right">'||
            to_char(round(CHNG/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(CHNG/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Physical Reads</TD><TD ALIGN="right">'||
            to_char(round(PHYR/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PHYR/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Physical Writes</TD><TD ALIGN="right">'||
            to_char(round(PHYW/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PHYW/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">User Calls</TD><TD ALIGN="right">'||
            to_char(round(UCAL/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(UCAL/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Parses</TD><TD ALIGN="right">'||
            to_char(round(PRSE/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(PRSE/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Hard Parses</TD><TD ALIGN="right">'||
            to_char(round(HPRS/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(HPRS/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Sorts</TD><TD ALIGN="right">'||
            to_char(round((SRTM+SRTD)/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round((SRTM+SRTD)/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Logons</TD><TD ALIGN="right">'||
            to_char(round(LOGC/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(LOGC/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Executes</TD><TD ALIGN="right">'||
            to_char(round(EXE/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">'||
	    to_char(round(EXE/TRAN,2),'9,999,990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Transactions</TD><TD ALIGN="right">'||
            to_char(round(TRAN/ELA,2),'99,999,999,990.00')||
            '</TD><TD ALIGN="right">&nbsp;</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Instance Efficiency Percentages
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="efficiency">Instance Efficiency Percentages (Target: 100%)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Efficiency (%)</TH></TR>';
  print(L_LINE);
  IF RENT = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*(1-BFWT/GETS),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Buffer Nowait</TD><TD ALIGN="right">'||
            to_char(round(100*(1-BFWT/GETS),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Redo Nowait</TD><TD ALIGN="right">'||
            S1||'</TD></TR>';
  print(L_LINE);
  IF (SRTM+SRTD) = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*SRTM/(SRTD+SRTM),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Buffer Hit</TD><TD ALIGN="right">'||
            to_char(round(100*(1-(PHYR-PHYRD-PHYRDL)/GETS),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>In-Memory Sort</TD><TD ALIGN="right">'||
            S1||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Library Hit</TD><TD ALIGN="right">'||
            to_char(round(100*LHTR,2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Soft Parse</TD><TD ALIGN="right">'||
            to_char(round(100*(1-HPRS/PRSE),2),'990.00')||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Execute to Parse</TD><TD ALIGN="right">'||
            to_char(round(100*(1-PRSE/EXE),2),'990.00')||'</TD></TR>'||
            ' <TR><TD>Latch Hit</TD><TD ALIGN="right">'||
            to_char(round(100*(1-LHR),2),'990.00')||'</TD></TR>';
  print(L_LINE);
  IF PRSELA = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := to_char(round(100*PRSCPU/PRSELA,2),'990.00');
  END IF;
  IF TCPU = 0
  THEN S2 := '&nbsp;';
  ELSE S2 := to_char(round(100*(1-(PRSCPU/TCPU)),2),'990.00');
  END IF;
  L_LINE := ' <TR><TD>Parse CPU to Parse Elapsed</TD><TD ALIGN="right">'||
            S1||'</TD></TR>'||
            ' <TR><TD>Non-Parse CPU</TD><TD ALIGN="right">'||
            S2||'</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Shared Pool Stats
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sharedpool">Shared Pool Statistics</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Begin</TH>'||
	    '<TH CLASS="th_sub">End</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD CLASS="td_name">Memory Usage %</TD><TD>'||
            to_char(round(100*(1-BFRM/BSPM),2),'990.00')||'</TD><TD>'||
	    to_char(round(100*(1-EFRM/ESPM),2),'990.00')||'</TD></TR>';
  print(L_LINE);
  FOR R_SPSQL IN C_SPSQL(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">% SQL with executions &gt; 1</TD><TD>'||
              to_char(round(R_SPSQL.b_single_sql,2),'990.00')||'</TD><TD>'||
	      to_char(round(R_SPSQL.e_single_sql,2),'990.00')||'</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD CLASS="td_name">% Memory for SQL with executions &gt; 1</TD><TD>'||
              to_char(round(R_SPSQL.b_single_mem,2),'990.00')||'</TD><TD>'||
	      to_char(round(R_SPSQL.e_single_mem,2),'990.00')||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Top 5 Wait Events
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
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- All Wait Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="waitevents">All Wait Events</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
	    '(desc), Waits (desc); idle events last</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	    '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time (s)</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wait Time (ms)</TH><TH CLASS="th_sub">'||
            'Waits/TXN</TH></TR>';
  print(L_LINE);
  FOR R_AllWait IN C_AllWait(DBID,INST_NUM,BID,EID,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_AllWait.event||'</TD><TD ALIGN="right">'||
              R_AllWait.waits||'</TD><TD ALIGN="right">'||R_AllWait.timeouts||'</TD><TD ALIGN="right">'||
	      R_AllWait.time||'</TD><TD ALIGN="right">'||R_AllWait.wt||'</TD><TD ALIGN="right">'||
	      R_AllWait.txwaits||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- BG Wait Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="#bgwaitevents">Background Wait Events</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">Ordered by Total Wait Time '||
	    '(desc), Waits (desc); idle events last</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waits</TH>'||
	    '<TH CLASS="th_sub">Timeouts</TH><TH CLASS="th_sub">Total Wt Time (s)</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wait Time (ms)</TH><TH CLASS="th_sub">'||
            'Waits/TXN</TH></TR>';
  print(L_LINE);
  FOR R_BGWait IN C_BGWait(DBID,INST_NUM,BID,EID,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_BGWait.event||'</TD><TD ALIGN="right">'||
              R_BGWait.waits||'</TD><TD ALIGN="right">'||R_BGWait.timeouts||'</TD><TD ALIGN="right">'||
	      R_BGWait.time||'</TD><TD ALIGN="right">'||R_BGWait.wt||'</TD><TD ALIGN="right">'||
	      R_BGWait.txwaits||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Wait Objects
  S1 := 'istats$waitobjects'; I1 := 1; I2 := 0;
  tab_exists(S1,I1,I2);
  IF I2 = 1
  THEN
    get_waitobj(DBID,INST_NUM,BID,EID);
  END IF;

  -- SQL by Gets
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="sqlbygets">Top '||TOP_N_SQL||' SQL ordered by Gets</A></TH></TR>'||
            CHR(10)||' <TR><TD COLSPAN="7" ALIGN="center">End Buffer Gets Treshold: '||EBGT;
  print(L_LINE);
  L_LINE := '<P ALIGN="justify" STYLE="margin-top:4">Note that resources reported for PL/SQL includes the '||
            'resources used by all SQL statements called within the PL/SQL code.'||
            ' As individual SQL statements are also reported, ';
  print(L_LINE);
  L_LINE := 'it is possible and valid for the summed total % to exceed 100.<BR>'||
            'If your primary tuning goal is reducing resource usage, start tuning '||
	    'these statements/objects ';
  print(L_LINE);
  L_LINE := '(CPU) plus <A HREF="#sqlbyreads">SQL by Reads</A> (File IO).</P></TD></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Buffer Gets</TH><TH CLASS="th_sub">Executions</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Gets per Exec</TH>'||
            '<TH CLASS="th_sub">% Total</TH><TH CLASS="th_sub">CPU Time (s)</TH>'||
            '<TH CLASS="th_sub">Elapsed Time (s)</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  print(L_LINE);
  FOR R_SQL IN C_SQLByGets(DBID,INST_NUM,BID,EID,GETS) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.bufgets||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.getsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.pcttotal||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_SQL.cputime||'</TD><TD ALIGN="right">'||R_SQL.elapsed||
              '</TD><TD ALIGN="right">'||R_SQL.hashval||'</TD></TR>'||CHR(10)||
	      ' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    print(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := R_Statement.sql_text;
      print(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- SQL by Reads
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="sqlbyreads">Top '||TOP_N_SQL||' SQL ordered by Reads</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="7" ALIGN="center">End Disk Reads Treshold: '||EDRT||
	    '<BR>If your primary tuning ';
  print(L_LINE);
  L_LINE := 'goal is to reduce resource usage, start by tuning these '||
            'statements/objects (File IO) plus <A HREF="#sqlbygets">SQL by '||
	    'Gets (CPU)</A>.</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Pysical Reads</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">Reads per Exec</TH><TH CLASS="th_sub">% Total</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">CPU Time (s)</TH><TH CLASS="th_sub">'||
            'Elapsed Time (s)</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  print(L_LINE);
  FOR R_SQL IN C_SQLByReads(DBID,INST_NUM,BID,EID,PHYR) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.phyreads||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.readsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.pcttotal||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_SQL.cputime||'</TD><TD ALIGN="right">'||R_SQL.elapsed||
              '</TD><TD ALIGN="right">'||R_SQL.hashval||'</TD></TR>'||CHR(10)||
	      ' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    print(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      print(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- SQL by Executions
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="sqlbyexec">Top '||TOP_N_SQL||' SQL ordered by Executions</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="6" ALIGN="center">End Executions Treshold: '||EET||
	    '<BR>Start with tuning these ';
  print(L_LINE);
  L_LINE := 'statements if your primary goal is to increase the response time.</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Executions</TH><TH CLASS="th_sub">Rows Processed</TH>'||
	    '<TH CLASS="th_sub">Rows per Exec</TH><TH CLASS="th_sub">CPU per Exec (s)</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Elap per Exec (s)</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  print(L_LINE);
  FOR R_SQL IN C_SQLByExec(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.execs||'</TD><TD ALIGN="right">'||
              R_SQL.rowsproc||'</TD><TD ALIGN="right">'||R_SQL.rowsperexec||
	      '</TD><TD ALIGN="right">'||R_SQL.cputime||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_SQL.elapsed||'</TD><TD ALIGN="right">'||R_SQL.hashval||
              '</TD></TR>'||CHR(10)||' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    print(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      print(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- SQL by Parse
  get_parsecpupct(DBID,INST_NUM,BID,EID,S1);
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="sqlbyparse">Top '||TOP_N_SQL||' SQL ordered by Parse Calls</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="4" ALIGN="center">End Parse Calls Treshold: '||EPC||
	    '<BR>Consider tuning these ';
  print(L_LINE);
  L_LINE := 'statements/objects, if the percentage of CPU used for parsing is high. '||
            'Currently, parsing takes avg. '||S1||'% of all CPU usage by all sessions.</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Parse Calls</TH><TH CLASS="th_sub">Executions</TH>'||
	    '<TH CLASS="th_sub">% Total Parses</TH><TH CLASS="th_sub">Hash Value</TH></TR>';
  print(L_LINE);
  FOR R_SQL IN C_SQLByParse(DBID,INST_NUM,BID,EID,PRSE) LOOP
    L_LINE := ' <TR><TD ALIGN="right">'||R_SQL.parses||'</TD><TD ALIGN="right">'||
              R_SQL.execs||'</TD><TD ALIGN="right">'||R_SQL.pctparses||
	      '</TD><TD ALIGN="right">'||R_SQL.hashval||
              '</TD></TR>'||CHR(10)||' <TR><TD>&nbsp;</TD><TD COLSPAN="6">';
    print(L_LINE);
    FOR R_Statement IN C_GetSQL(R_SQL.hashval) LOOP
      L_LINE := trim(R_Statement.sql_text);
      print(L_LINE);
    END LOOP;
    L_LINE := '</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Instance Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="instact">Instance Activity Stats</A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Total</TH>'||
	    '<TH CLASS="th_sub">per Second</TH><TH CLASS="th_sub">per TXN</TH></TR>';
  print(L_LINE);
  FOR R_Inst IN C_InstAct(DBID,INST_NUM,BID,EID,ELA,TRAN) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Inst.name||'</TD><TD ALIGN="right">'||
              R_Inst.total||'</TD><TD ALIGN="right">'||R_Inst.sec||
	      '</TD><TD ALIGN="right">'||R_Inst.txn||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- TS IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="tsio">TableSpace IO Summary Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">Ordered by IOs (Reads + Writes)'||
	    ' desc<DIV ALIGN="justify">';
  print(L_LINE);
  L_LINE := 'If the value for Avg Blks/Rd is higher than 1, this indicates full '||
            'table scans. If it grows higher than <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> '||
	    'we must assume that ';
  print(L_LINE);
  L_LINE := 'almost every operation on this TS is executed as full table scan '||
            'instead of using an index first, so you should consider creating '||
	    'appropriate indices ';
  print(L_LINE);
  L_LINE := 'or, maybe, increasing the <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE>.</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Reads</TH>'||
	    '<TH CLASS="th_sub">AvgReads/s</TH><TH CLASS="th_sub">AvgRd (ms)</TH>'||
	    '<TH CLASS="th_sub">Avg Blks/Rd</TH>';
  print(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Writes</TH><TH CLASS="th_sub">Avg Wrt/s</TH>'||
           '<TH CLASS="th_sub">Buffer Waits</TH><TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
  print(L_LINE);
  FOR R_TSIO IN C_TSIO(DBID,INST_NUM,BID,EID,ELA) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right">'||R_TSIO.avgrd||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_TSIO.bpr||'</TD><TD ALIGN="right">'||R_TSIO.writes||
              '</TD><TD ALIGN="right">'||R_TSIO.wps||'</TD><TD ALIGN="right">'||
	      R_TSIO.waits||'</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- File IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="fileio">File IO Summary Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="10" ALIGN="center">Ordered by TableSpace, File'||
	    '<DIV ALIGN="justify">';
  print(L_LINE);
  L_LINE := 'If the value for Avg Blks/Rd is higher than 1, this indicates full '||
            'table scans. If it grows higher than <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE> '||
	    'we must assume that ';
  print(L_LINE);
  L_LINE := 'almost every operation on this TS is executed as full table scan '||
            'instead of using an index first, so you should consider creating '||
	    'appropriate indices ';
  print(L_LINE);
  L_LINE := 'or, maybe, increasing the <CODE>DB_FILE_MULTIBLOCK_READ_COUNT</CODE>.'||
            '<BR>Average Read Times (AvgRd) of greater than 20..40ms should be '||
	    'considered slow for ';
  print(L_LINE);
  L_LINE := 'single block reads. So if this is the case, you should check whether '||
            'the disks are capable of the required IO rates. If they are, your '||
	    'file-to-disk layout ';
  print(L_LINE);
  L_LINE := 'may be causing some disks to be underused while others are overly '||
            'busy. Furthermore, if the temporary TableSpaces have the most write '||
	    'activity, this may indicate';
  print(L_LINE);
  L_LINE := 'that too much of the sorting is to disk and may require optimization.</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Filename</TH>'||
            '<TH CLASS="th_sub">Reads</TH><TH CLASS="th_sub">AvgReads/s</TH>'||
	    '<TH CLASS="th_sub">AvgRd (ms)</TH>';
  print(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Avg Blks/Rd</TH><TH CLASS="th_sub">Writes</TH>'||
           '<TH CLASS="th_sub">Avg Wrt/s</TH><TH CLASS="th_sub">Buffer Waits</TH>'||
	   '<TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
  print(L_LINE);
  FOR R_TSIO IN C_FileIO(DBID,INST_NUM,BID,EID,ELA) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD CLASS="td_name">'||
              R_TSIO.filename||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right">'||R_TSIO.avgrd||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_TSIO.bpr||'</TD><TD ALIGN="right">'||R_TSIO.writes||
              '</TD><TD ALIGN="right">'||R_TSIO.wps||'</TD><TD ALIGN="right">'||
	      R_TSIO.waits||'</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Buffer Pool
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="bufpool">Buffer Pool Statistics</A></TH></TR>'||
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
  FOR R_Buff IN C_BuffP(DBID,INST_NUM,BID,EID,BS) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.name||'</TD><TD ALIGN="right">'||
              R_Buff.numbufs||'</TD><TD ALIGN="right">'||
              R_Buff.hitratio||'</TD><TD ALIGN="right">'||R_Buff.gets||
	      '</TD><TD ALIGN="right">'||R_Buff.phread||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_Buff.phwrite||'</TD><TD ALIGN="right">'||R_Buff.fbwait||
              '</TD><TD ALIGN="right">'||R_Buff.wcwait||'</TD><TD ALIGN="right">'||
	      R_Buff.bbwait||'</TD><TD ALIGN="right">'||R_Buff.ratio||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Instance Recovery
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="recover">Instance Recovery Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Target MTTR (s)</TH>'||
            '<TH CLASS="th_sub">Estd MTTR (s)</TH><TH CLASS="th_sub">Recovery Estd IOs</TH>'||
	    '<TH CLASS="th_sub">Actual Redo Blks</TH>';
  print(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Target Redo Blks</TH><TH CLASS="th_sub">LogFile Size Redo Blks</TH>'||
           '<TH CLASS="th_sub">Log Ckpt Timeout Redo Blks</TH>'||
	   '<TH CLASS="th_sub">Log Ckpt Interval Redo Blks</TH></TR>';
  print(L_LINE);
  FOR R_Reco IN C_Recover(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Reco.name||'</TD><TD ALIGN="right">'||
              R_Reco.tm||'</TD><TD ALIGN="right">'||R_Reco.em||
	      '</TD><TD ALIGN="right">'||R_Reco.rei||'</TD><TD ALIGN="right">'||
	      R_Reco.arb||'</TD><TD ALIGN="right">';
    print(L_LINE);
    L_LINE := R_Reco.trb||'</TD><TD ALIGN="right">'||R_Reco.lfrb||
              '</TD><TD ALIGN="right">'||R_Reco.lctrb||'</TD><TD ALIGN="right">'||
	      R_Reco.lcirb||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Buffer Waits
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="bufwait">Buffer Wait Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Ordered by Wait Time desc, Waits desc';
  print(L_LINE);
  L_LINE := '<DIV ALIGN="justify">If Waits/s are high for a given class, you may '||
            'consider some tuning: For the undo headers/blocks, adding more rollback '||
	    'segments can help.';
  print(L_LINE);
  L_LINE := 'With data blocks, increasing the size of the database buffer cache '||
            'can reduce these waits. Segment header waits generally point to the '||
	    'need to add freelists to the affected table. ';
  print(L_LINE);
  L_LINE := 'Freelist block waits indicate that the affected segment needs a '||
            'higher number of freelists - for the Oracle Parallel Server, make '||
	    'sure each instance has its own freelist groups.</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Class</TH><TH CLASS="th_sub">Waits</TH>'||
            '<TH CLASS="th_sub">Tot Wait Time (s)</TH>'||
	    '<TH CLASS="th_sub">Avg Wait Time (s)</TH>'||
	    '<TH CLASS="th_sub">Waits/s</TH></TR>';
  print(L_LINE);
  FOR R_Buff IN C_BuffW(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Buff.class||'</TD><TD ALIGN="right">'||
              R_Buff.icnt||'</TD><TD ALIGN="right">'||R_Buff.itim||
	      '</TD><TD ALIGN="right">'||R_Buff.iavg;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||R_Buff.wps||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- PGA Aggreg Target Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="pga">PGA Aggreg Target Memory Statistics</A></TH></TR>'||
            ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">PGA Aggreg Target (M)</TH>'||
            '<TH CLASS="th_sub">PGA in Use (M)</TH><TH CLASS="th_sub">W/A PGA in Use (M)</TH>'||
	    '<TH CLASS="th_sub">1-Pass Mem Req (M)</TH>';
  print(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">% Optim W/A Execs</TH><TH CLASS="th_sub">% Non-W/A PGA Memory</TH>'||
           '<TH CLASS="th_sub">% Auto W/A PGA Mem</TH>'||
	   '<TH CLASS="th_sub">% Manual W/A PGA Mem</TH></TR>';
  print(L_LINE);
  FOR R_PGAA IN C_PGAA(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAA.snap||'</TD><TD ALIGN="right">'||
              R_PGAA.pgaat||'</TD><TD ALIGN="right">'||R_PGAA.tot_pga_used||
	      '</TD><TD ALIGN="right">'||R_PGAA.tot_tun_used;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||R_PGAA.onepr||'</TD><TD ALIGN="right">'||
              R_PGAA.opt_pct||'</TD><TD ALIGN="right">'||R_PGAA.pct_unt||
	      '</TD><TD ALIGN="right">'||R_PGAA.pct_auto_tun||
	      '</TD><TD ALIGN="right">'||R_PGAA.pct_man_tun||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- PGA Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4">PGA Memory Statistics</TH></TR>'||
            ' <TR><TD COLSPAN="4" ALIGN="center">WorkArea (W/A) memory is used for: sort, bitmap merge, and hash join ops</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Begin (M)</TH>'||
            '<TH CLASS="th_sub">End (M)</TH><TH CLASS="th_sub">% Diff</TH></TR>';
  print(L_LINE);
  FOR R_PGAM IN C_PGAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAM.st||'</TD><TD ALIGN="right">'||
              R_PGAM.snap1||'</TD><TD ALIGN="right">'||R_PGAM.snap2||
	      '</TD><TD ALIGN="right">'||R_PGAM.diff||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Enqueue Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="enq">Enqueue Activity</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">Enqueue Stats gathered prior to 9i '||
	    'should not be compared with 9i data<BR>Ordered by Waits desc, Requests desc';
  print(L_LINE);
  L_LINE := '<DIV ALIGN="justify">TX means transaction locks, indicating multiple '||
            'users try modifying the same row in the database (row-level lock). '||
	    'TM stands for Table locks and point to the possibility ';
  print(L_LINE);
  L_LINE := 'of e.g. foreign key constraints not being indexed. ST notes '||
            'space-management locks which could be caused by using permanent '||
	    'tablespaces for sorting (rather than temporary), ';
  print(L_LINE);
  L_LINE := 'or by dynamic allocation resulting from inadequate storage clauses. '||
            'In the latter case, using locally-managed tablespaces may help you '||
	    'avoiding this problem.</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Eq</TH><TH CLASS="th_sub">Requests</TH>'||
            '<TH CLASS="th_sub">Succ Gets</TH><TH CLASS="th_sub">Failed Gets</TH>'||
	    '<TH CLASS="th_sub">Waits</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg Wt Time (ms)</TH><TH CLASS="th_sub">'||
            'Wait Time (s)</TH></TR>';
  print(L_LINE);
  FOR R_Enq IN C_Enq(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_Enq.name||'</TD><TD ALIGN="right">'||
              R_Enq.reqs||'</TD><TD ALIGN="right">'||R_Enq.sreq||
	      '</TD><TD ALIGN="right">'||R_Enq.freq||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_Enq.waits||'</TD><TD ALIGN="right">'||
              R_Enq.awttm||'</TD><TD ALIGN="right">'||R_Enq.wttm||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- RBS Stats
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="#rbs">Rollback Segments Stats</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">A high value for "Pct Waits" '||
	    'suggests more rollback segments may be required<BR>RBS stats may ';
  print(L_LINE);
  L_LINE := 'not be accurate between begin and end snaps when using Auto Undo '||
            'Management, as RBS may be dynamically created and dropped as needed</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">RBS#</TH><TH CLASS="th_sub">Trans Table Gets</TH>'||
            '<TH CLASS="th_sub">Pct Waits</TH><TH CLASS="th_sub">Undo Bytes Written</TH>'||
	    '<TH CLASS="th_sub">Wraps</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Shrinks</TH><TH CLASS="th_sub">'||
            'Extends</TH></TR>';
  print(L_LINE);
  FOR R_RBS IN C_RBS(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
              R_RBS.gets||'</TD><TD ALIGN="right">'||R_RBS.waits||
	      '</TD><TD ALIGN="right">'||R_RBS.writes||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_RBS.wraps||'</TD><TD ALIGN="right">'||
              R_RBS.shrinks||'</TD><TD ALIGN="right">'||R_RBS.extends||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- RBS Storage
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Rollback Segments Storage</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Optimal Size should be larger '||
	    'than Avg Active</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">RBS#</TH><TH CLASS="th_sub">Segment Size</TH>'||
            '<TH CLASS="th_sub">Avg Active</TH><TH CLASS="th_sub">Optimal Size</TH>'||
	    '<TH CLASS="th_sub">Maximum Size</TH></TR>';
  print(L_LINE);
  FOR R_RBS IN C_RBST(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
              R_RBS.rssize||'</TD><TD ALIGN="right">'||R_RBS.active||
	      '</TD><TD ALIGN="right">'||R_RBS.optsize||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_RBS.hwmsize||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Undo Segs Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="undo">Undo Segment Summary</A></TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">Undo Segment block stats<BR>'||
	    'uS - unexpired Stolen, uR - unexpired Released, uU - unexpired reUsed<BR>';
  print(L_LINE);
  L_LINE := 'eS - expired Stolen, eR - expired Released, eU - expired reUsed</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Undo TS#</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
            '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	    '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
            'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
  print(L_LINE);
  FOR R_USS IN C_USS(DBID,INST_NUM,BID,EID,BTIME,ETIME) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.undotsn||'</TD><TD ALIGN="right">'||
              R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	      '</TD><TD ALIGN="right">'||R_USS.maxq||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
              R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	      R_USS.blkst||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Undo Segs Stat
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Undo Segment Statistics</TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">Ordered by Time desc</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">End Time</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
            '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	    '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
            'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
  print(L_LINE);
  FOR R_USS IN C_UST(DBID,INST_NUM,BID,EID,BTIME,ETIME) LOOP
    L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.endt||'</TD><TD ALIGN="right">'||
              R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	      '</TD><TD ALIGN="right">'||R_USS.maxq||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
              R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	      R_USS.blkst||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Latch Activity
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="latches">Latch Activity</A></TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">"Get Requests", "Pct Get Miss"'||
	    ' and "Avg Slps/Miss" are statistics for willing-to-wait';
  print(L_LINE);
  L_LINE := ' latch get requests<BR>"NoWait Requests", "Pct NoWait Miss" are '||
            'for no-wait latch get requests<BR>"Pct Misses" for both should be '||
	    'very close to 0.0<BR>';
  print(L_LINE);
  L_LINE := 'Ordered by Wait Time desc, Avg Slps/Miss, Pct NoWait Miss desc</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Get Miss</TH><TH CLASS="th_sub">Avg Slps/Miss</TH>'||
	    '<TH CLASS="th_sub">Wait Time (s)</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">NoWait Requests</TH><TH CLASS="th_sub">'||
            'Pct NoWait Miss</TH></TR>';
  print(L_LINE);
  FOR R_LA IN C_LAA(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
              R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.missed||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_LA.wt||'</TD><TD ALIGN="right">'||
              R_LA.nowai||'</TD><TD ALIGN="right">'||R_LA.imiss||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Latch Sleep Breakdown
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Latch Sleep Breakdown</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Ordered by Misses desc</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Misses</TH><TH CLASS="th_sub">Sleeps</TH>'||
	    '<TH CLASS="th_sub">Spin & Sleeps 1-&gt;4</TH></TR>';
  print(L_LINE);
  FOR R_LA IN C_LAS(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.name||'</TD><TD ALIGN="right">'||
              R_LA.gets||'</TD><TD ALIGN="right">'||R_LA.misses||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="center">'||R_LA.sleep4||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Latch Miss Sources
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Latch Miss Sources</TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">Only Latches with Sleeps are '||
	    'shown<BR>Ordered by Name, Sleeps desc</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Where</TH>'||
            '<TH CLASS="th_sub">NoWait Misses</TH><TH CLASS="th_sub">Sleeps</TH>'||
	    '<TH CLASS="th_sub">Waiter Sleeps</TH></TR>';
  print(L_LINE);
  FOR R_LA IN C_LAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.parent||'</TD><TD>'||
              R_LA.where_from||'</TD><TD ALIGN="right">'||R_LA.nwmisses||
	      '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_LA.waiter_sleeps||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Dictionary Cache
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="caches">Dictionary Cache</A></TH></TR>'||
            ' <TR><TD COLSPAN="8" ALIGN="center">"Pct Misses" should be very '||
	    ' low (&lt; 2% in most cases)<BR>';
  print(L_LINE);
  L_LINE := '"Cache Usage" is the number of cache entries being used<BR>'||
            '"Pct SGA" is the ratio of usage to allocated size for that cache</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Miss</TH><TH CLASS="th_sub">Scan Reqs</TH>'||
	    '<TH CLASS="th_sub">Pct Miss</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Mod Reqs</TH><TH CLASS="th_sub">Final Usage</TH>'||
            '<TH CLASS="th_sub">Pct SGA</TH></TR>';
  print(L_LINE);
  FOR R_CA IN C_CAD(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_CA.param||'</TD><TD ALIGN="right">'||
              R_CA.gets||'</TD><TD ALIGN="right">'||R_CA.getm||
	      '</TD><TD ALIGN="right">'||R_CA.scans||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_CA.scanm||'</TD><TD ALIGN="right">'||
              R_CA.mods||'</TD><TD ALIGN="right">'||R_CA.usage||
	      '</TD><TD ALIGN="right">'||R_CA.sgapct||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Library Cache
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7">Library Cache</TH></TR>'||
            ' <TR><TD COLSPAN="7" ALIGN="center">"Pct Misses" should be very low</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">NameSpace</TH><TH CLASS="th_sub">Get Requests</TH>'||
            '<TH CLASS="th_sub">Pct Miss</TH><TH CLASS="th_sub">Pin Reqs</TH>'||
	    '<TH CLASS="th_sub">Pct Miss</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Reloads</TH><TH CLASS="th_sub">Invalidations</TH></TR>';
  print(L_LINE);
  FOR R_CA IN C_CAM(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_CA.namespace||'</TD><TD ALIGN="right">'||
              R_CA.gets||'</TD><TD ALIGN="right">'||R_CA.getm||
	      '</TD><TD ALIGN="right">'||R_CA.pins||'</TD>';
    print(L_LINE);
    L_LINE := '<TD ALIGN="right">'||R_CA.pinm||'</TD><TD ALIGN="right">'||
              R_CA.reloads||'</TD><TD ALIGN="right">'||R_CA.inv||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- SGA Memory Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="sga">SGA Memory Summary</A></TH></TR>'||
            ' <TR><TD COLSPAN="2" ALIGN="center">Values at the time of the End SnapShot</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">SGA Region</TH><TH CLASS="th_sub">Size in Bytes</TH>';
  print(L_LINE);
  I1 := 0;
  FOR R_SGASum in C_SGASum(DBID,INST_NUM,BID,EID) LOOP
    I1 := I1 + R_SGASum.rawval;
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.name||'</TD><TD ALIGN="right">'||
              R_SGASum.val||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD>Sum</TD><TD ALIGN="right">'||to_char(I1,'999,999,999,990')||
            '</TD></TR>'||TABLE_CLOSE;
  print(L_LINE);

  -- SGA breakdown diff
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">SGA BreakDown Difference</TH></TR>'||
            ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Name</TH>'||
	    '<TH CLASS="th_sub">Begin Value</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">End Value</TH><TH CLASS="th_sub">% Diff</TH></TR>';
  print(L_LINE);
  FOR R_SGASum in C_SGABreak(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.pool||'</TD><TD CLASS="td_name">'||
              R_SGASum.name||'</TD><TD ALIGN="right">'||R_SGASum.snap1||
	      '</TD><TD ALIGN="right">'||R_SGASum.snap2||'</TD><TD ALIGN="right">'||
	      R_SGASum.diff||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Resource Limits
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="resourcelimits">Resource Limits</A></TH></TR>'||
            ' <TR><TD COLSPAN="5" ALIGN="center">"Current" is the time of the End SnapShot</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Resource</TH><TH CLASS="th_sub">Curr Utilization</TH>'||
	    '<TH CLASS="th_sub">Max Utilization</TH><TH CLASS="th_sub">'||
	    'Init Allocation</TH><TH CLASS="th_sub">Limit</TH></TR>';
  print(L_LINE);
  FOR R_RLim in C_RLim(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_RLim.rname||'</TD><TD ALIGN="right">'||
              R_RLim.curu||'</TD><TD ALIGN="right">'||R_RLim.maxu||
	      '</TD><TD ALIGN="right">'||R_RLim.inita||'</TD><TD ALIGN="right">'||
	      R_RLim.lim||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Init.Ora Params
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="initora">Initialization Parameters (init.ora)</A></TH></TR>'||
            ' <TR><TH CLASS="th_sub">Parameter Name</TH><TH CLASS="th_sub">Begin Value</TH>'||
	    '<TH CLASS="th_sub">End Value (if different)</TH></TR>';
  print(L_LINE);
  FOR R_IParm in C_IParm(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_IParm.name||'</TD><TD>'||
              R_IParm.bval||'</TD><TD>'||R_IParm.eval||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);


  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  print(L_LINE);
  L_LINE := '<TR><TD><DIV CLASS="small">Created by OSPRep v'||OSPVER||' &copy; 2003 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></DIV></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off
