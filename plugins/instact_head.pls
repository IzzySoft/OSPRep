
  PROCEDURE instact IS
    CURSOR C_InstAct (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, ela IN NUMBER, tran IN NUMBER) IS
      SELECT b.name name,
             to_char(e.value - b.value,'99,999,999,999,990') total,
	     to_char(round((e.value - b.value)/ela,2),'99,999,999,990.00') sec,
	     to_char(round((e.value - b.value)/tran,2),'99,999,999,990.00') txn
        FROM stats$sysstat b, stats$sysstat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.name    = e.name
         AND e.name NOT IN ( 'logons current','opened cursors current','workarea memory allocated')
         AND e.value   > b.value
         AND e.value   > 0
       ORDER BY b.name;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="instact">Instance Activity Stats</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'instact'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" VALIGN="middle"></A></TH></TR>';
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
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

