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
    get_plan(BID,EID,R_SQL.hashval);
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
    get_plan(BID,EID,R_SQL.hashval);
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
    get_plan(BID,EID,R_SQL.hashval);
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
    get_plan(BID,EID,R_SQL.hashval);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

