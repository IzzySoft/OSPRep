  FUNCTION have_enqs (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) RETURN BOOLEAN IS
    CI NUMBER;
    BEGIN
      SELECT COUNT(*) INTO CI
        FROM stats$enqueue_stat b, stats$enqueue_stat e
       WHERE b.snap_id(+) = bid
         AND e.snap_id    = eid
         AND b.dbid(+)    = db_id
         AND e.dbid       = db_id
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = instnum
         AND e.instance_number    = instnum
         AND b.instance_number(+) = e.instance_number
         AND b.eq_type(+) = e.eq_type
         AND e.total_wait# - nvl(b.total_wait#,0) > 0;
      IF CI > 0 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE enqact IS
    CURSOR C_Enq (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT e.eq_type name,
             to_char(e.total_req# - nvl(b.total_req#,0),'99,999,999') reqs,
             to_char(e.succ_req#  - nvl(b.succ_req#,0),'99,999,999') sreq,
	     to_char(e.failed_req# - nvl(b.failed_req#,0),'99,999,999') freq,
             to_char(100*((e.failed_req# - nvl(b.failed_req#,0))/
                   (e.total_req# - nvl(b.total_req#,0))),'990.00') pctfail,
	     to_char(e.total_wait# - nvl(b.total_wait#,0),'999,999') waits,
             to_char(decode( (e.total_wait# - nvl(b.total_wait#,0)),
	                   0, to_number(NULL),
			   (  (e.cum_wait_time - nvl(b.cum_wait_time,0))
			    / (e.total_wait# - nvl(b.total_wait#,0))
			   ) ),'999,999,990.00') awttm,
	     to_char((e.cum_wait_time - nvl(b.cum_wait_time,0))/1000,
	            '999,999') wttm
        FROM stats$enqueue_stat b, stats$enqueue_stat e
       WHERE b.snap_id(+) = bid
         AND e.snap_id    = eid
         AND b.dbid(+)    = db_id
         AND e.dbid       = db_id
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = instnum
         AND e.instance_number    = instnum
         AND b.instance_number(+) = e.instance_number
         AND b.eq_type(+) = e.eq_type
         AND e.total_wait# - nvl(b.total_wait#,0) > 0
       ORDER BY waits desc, reqs desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="enq">Enqueue Activity</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'enqwaits'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" VALIGN="middle"></A></TH></TR>';
      print(L_LINE);
      L_LINE:=  ' <TR><TD COLSPAN="8" ALIGN="center">Enqueue Stats gathered prior to 9i '||
                'should not be compared with 9i data<BR>Ordered by Waits desc, Requests desc';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Eq</TH><TH CLASS="th_sub">Requests</TH>'||
                '<TH CLASS="th_sub">Succ Gets</TH><TH CLASS="th_sub">Failed Gets</TH>'||
	        '<TH CLASS="th_sub">PctFail</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Waits</TH><TH CLASS="th_sub">Avg Wt Time (ms)'||
                '</TH><TH CLASS="th_sub">Wait Time (s)</TH></TR>';
      print(L_LINE);
      FOR R_Enq IN C_Enq(DBID,INST_NUM,BID,EID) LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_Enq.name||'</TD><TD ALIGN="right">'||
                  R_Enq.reqs||'</TD><TD ALIGN="right">'||R_Enq.sreq||
	          '</TD><TD ALIGN="right">'||R_Enq.freq||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_Enq.pctfail||'</TD><TD ALIGN="right">'||
                  R_Enq.waits||'</TD><TD ALIGN="right">'||R_Enq.awttm||
                  '</TD><TD ALIGN="right">'||R_Enq.wttm||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
