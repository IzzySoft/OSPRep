
  PROCEDURE sga_sum IS
    CURSOR C_SGASum (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT name,
             to_char(value,'999,999,999,990') val,
             value rawval
        FROM stats$sga
       WHERE snap_id = eid
         AND dbid    = db_id
         AND instance_number = instnum
       ORDER BY name;
    BEGIN
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE sga_break IS
    CURSOR C_SGABreak (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT nvl(replace(b.pool,'pool',''),'&nbsp;') pool,
             b.name name,
             to_char(b.bytes,'999,999,999,999') snap1,
	     to_char(e.bytes,'999,999,999,999') snap2,
             to_char(100* (e.bytes - b.bytes)/b.bytes,'9,990.00') diff
        FROM stats$sgastat b, stats$sgastat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.dbid    = e.dbid
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.instance_number = e.instance_number
         AND b.name    = e.name
         AND nvl(b.pool,'a')   = nvl(e.pool,'a')
       ORDER BY b.pool, b.name;
    BEGIN
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
