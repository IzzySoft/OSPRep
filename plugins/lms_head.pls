
  PROCEDURE lms IS
    CURSOR C_LAM IS
      SELECT e.parent_name parent,
             e.where_in_code where_from,
	     to_char(e.nwfail_count - nvl(b.nwfail_count,0),'99,999') nwmisses,
	     to_char(e.sleep_count - nvl(b.sleep_count,0),'9,999,999') sleeps,
	     to_char(e.wtr_slp_count - nvl(b.wtr_slp_count,0),'9,999,999') waiter_sleeps
        FROM stats$latch_misses_summary b, stats$latch_misses_summary  e
       WHERE b.snap_id(+) = BID
         AND e.snap_id    = EID
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.parent_name(+)     = e.parent_name
         AND b.where_in_code(+)   = e.where_in_code
         AND e.sleep_count > nvl(b.sleep_count,0)
       ORDER BY e.parent_name, sleeps desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Latch Miss Sources'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'latches'||CHR(39)||
		')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="12" ALIGN="middle" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="5" ALIGN="center">Only Latches with Sleeps are '||
	        'shown<BR>Ordered by Name, Sleeps desc</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Latch Name</TH><TH CLASS="th_sub">Where</TH>'||
                '<TH CLASS="th_sub">NoWait Misses</TH><TH CLASS="th_sub">Sleeps</TH>'||
	        '<TH CLASS="th_sub">Waiter Sleeps</TH></TR>';
      print(L_LINE);
      FOR R_LA IN C_LAM LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_LA.parent||'</TD><TD>'||
                  R_LA.where_from||'</TD><TD ALIGN="right">'||R_LA.nwmisses||
	          '</TD><TD ALIGN="right">'||R_LA.sleeps||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_LA.waiter_sleeps||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

