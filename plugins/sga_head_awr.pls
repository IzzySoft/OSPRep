
  PROCEDURE sga_sum IS
    /** SGA Memory Summary */
    SIZ VARCHAR2(10);
    CURSOR C_SGASum IS
      SELECT name,
             value val
        FROM stats$sga
       WHERE snap_id = EID
         AND dbid    = DB_ID
         AND instance_number = INST_NUM
       ORDER BY name;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="sga">SGA Memory Summary</A></TH></TR>'||
                ' <TR><TD COLSPAN="2" ALIGN="center">Values at the time of the End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">SGA Region</TH><TH CLASS="th_sub">Size</TH>';
      print(L_LINE);
      I1 := 0;
      FOR R_SGASum in C_SGASum LOOP
        SIZ := format_fsize(R_SGASum.val);
        I1 := I1 + R_SGASum.val;
        L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.name||'</TD><TD ALIGN="right">'||
                  SIZ||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      SIZ := format_fsize(I1);
      L_LINE := ' <TR><TD>Sum</TD><TD ALIGN="right">'||SIZ||
                '</TD></TR>'||TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE sga_advice IS
    /** SGA Target Advice -- AWR only */
    FSI NUMBER; SIZ VARCHAR2(20); FAC VARCHAR2(10); TIM VARCHAR2(15); EPR VARCHAR2(15);
    CURSOR C_Ad IS
      SELECT sga_size,
             sga_size_factor factor,
             estd_db_time dbtime,
             estd_physical_reads phyreads
        FROM dba_hist_sga_target_advice
       WHERE snap_id = EID
         AND dbid = DB_ID
         AND instance_number = INST_NUM
       ORDER BY factor;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="sga">SGA Target Advice</A></TH></TR>'||
                ' <TR><TD COLSPAN="4" ALIGN="center">Values at the time of the End SnapShot ('||EID||')</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub" TITLE="Value used for this estimation">SGA Size</TH>'||
                '<TH CLASS="th_sub" TITLE="Size factor based on current setting">Factor</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub" TITLE="Estimated DB Time">DBTime</TH>'||
                '<TH CLASS="th_sub" TITLE="Estimated Physical Reads">PhyReads</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Ad LOOP
        FSI := rec.sga_size*1.024*1024*1024; -- values are in "false MB"
        SIZ := format_fsize(FSI);
        FAC := TO_CHAR(rec.factor,'99.999');
        TIM := numformat(rec.dbtime);
        EPR := numformat(rec.phyreads);
        L_LINE := ' <TR><TD ALIGN="right">'||SIZ||'</TD><TD ALIGN="right">'||FAC||'</TD><TD ALIGN="right">'||TIM||'</TD><TD ALIGN="right">'||EPR||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE sga_break IS
    /** SGA BreakDown Difference */
    CURSOR C_SGABreak IS
      SELECT nvl(replace(b.pool,'pool',''),'&nbsp;') pool,
             b.name name,
             to_char(b.bytes,'999,999,999,999') snap1,
             to_char(e.bytes,'999,999,999,999') snap2,
             to_char(100* (e.bytes - b.bytes)/b.bytes,'9,990.00') diff
        FROM stats$sgastat b, stats$sgastat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
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
      FOR R_SGASum in C_SGABreak LOOP
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
