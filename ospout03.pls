
  SELECT TO_NUMBER(value) INTO I1
    FROM stats$parameter
   WHERE name='db_file_multiblock_read_count'
     AND snap_id = EID
     AND dbid    = DBID
     AND instance_number = INST_NUM;

  -- TS IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="tsio">TableSpace IO Summary Statistics</A>'||
            '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'fileio'||CHR(39)||
	    ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" VALIGN="middle"></A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="9" ALIGN="center">Ordered by IOs (Reads + Writes)'||
	    ' desc</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Reads</TH>'||
	    '<TH CLASS="th_sub">AvgReads/s</TH><TH CLASS="th_sub">AvgRd (ms)</TH>'||
	    '<TH CLASS="th_sub">Avg Blks/Rd</TH>';
  print(L_LINE);
  L_LINE:= '<TH CLASS="th_sub">Writes</TH><TH CLASS="th_sub">Avg Wrt/s</TH>'||
           '<TH CLASS="th_sub">Buffer Waits</TH><TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
  print(L_LINE);
  FOR R_TSIO IN C_TSIO(DBID,INST_NUM,BID,EID,ELA) LOOP
    S1 := alert_gt_warn(R_TSIO.bprn,I1*AR_TS_BLKRD/100,I1*WR_TS_BLKRD/100);
    S2 := alert_gt_warn(R_TSIO.avems,AR_TS_RD,WR_TS_RD);
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right"'||S2||'>'||R_TSIO.avgrd;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right"'||S1||'>'||R_TSIO.bpr||
              '</TD><TD ALIGN="right">'||R_TSIO.writes||'</TD><TD ALIGN="right">'||
	      R_TSIO.wps||'</TD><TD ALIGN="right">'||R_TSIO.waits||
	      '</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- File IO Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="fileio">File IO Summary Statistics</A>'||
            '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'fileio'||CHR(39)||
	    ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" VALIGN="middle"></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="10" ALIGN="center">Ordered by TableSpace, File'||
	    '</TD></TR>';
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
    S1 := alert_gt_warn(R_TSIO.bprn,I1*AR_TS_BLKRD/100,I1*WR_TS_BLKRD/100);
    S2 := alert_gt_warn(R_TSIO.avems,AR_TS_RD,WR_TS_RD);
    L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD CLASS="td_name">'||
              R_TSIO.filename||'</TD><TD ALIGN="right">'||
              R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	      '</TD><TD ALIGN="right"'||S2||'>'||R_TSIO.avgrd;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right"'||S1||'>'||R_TSIO.bpr||'</TD><TD ALIGN="right">'||
              R_TSIO.writes||'</TD><TD ALIGN="right">'||R_TSIO.wps||
	      '</TD><TD ALIGN="right">'||R_TSIO.waits||'</TD><TD ALIGN="right">'||
	      R_TSIO.avgbw||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

