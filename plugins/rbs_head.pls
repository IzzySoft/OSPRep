
  PROCEDURE rbs_stat IS
    CURSOR C_RBS (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT b.usn rbs#,
             to_char(e.gets - b.gets,'9,999,999,990.0') gets,
             to_char(to_number(decode(e.gets,b.gets,NULL,
	          (e.waits - b.waits) * 100 / (e.gets - b.gets) )),
		  '990.00') waits,
	     to_char(e.writes - b.writes,'999,999,999,990') writes,
             to_char(e.wraps - b.wraps,'999,999') wraps,
	     to_char(e.shrinks - b.shrinks,'999,999') shrinks,
             to_char(e.extends - b.extends,'999,999') extends
        FROM stats$rollstat b, stats$rollstat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.dbid    = e.dbid
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.instance_number = e.instance_number
         AND e.usn     = b.usn
       ORDER BY e.usn;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7">Rollback Segments Stats'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'rollstat'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	        'VALIGN="middle"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="7" ALIGN="justify">A high value for "Pct Waits" '||
                'suggests more rollback segments may be required. ';
      print(L_LINE);
      L_LINE := 'A large number of transaction table waits also results in high values '||
                'of "buffer busy waits" for undo segment header blocks; cross-reference '||
	        'with the <A HREF="#bufwait">Buffer Wait Statistics</A> ';
      print(L_LINE);
      L_LINE := 'to confirm this correlation.<DIV ALIGN="center">RBS stats may not '||
                'be accurate between begin and end snaps when using Auto Undo '||
                'Management, as RBS may be dynamically ';
      print(L_LINE);
      L_LINE := 'created and dropped as needed</TD></TR>';
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE rbs_stor IS
    CURSOR C_RBST (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT b.usn rbs#,
             to_char(e.rssize,'99,999,999,999') rssize,
             to_char(e.aveactive,'999,999,999') active,
	     nvl(to_char(to_number(decode(e.optsize,-4096,NULL,e.optsize)),
	           '99,999,999,999'),'&nbsp;') optsize,
             to_char(e.hwmsize,'99,999,999,999') hwmsize
        FROM stats$rollstat b, stats$rollstat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.dbid    = e.dbid
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.instance_number = e.instance_number
         AND e.usn     = b.usn
       ORDER BY e.usn;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">Rollback Segments Storage'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'rollstat'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	        'VALIGN="middle"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="5" ALIGN="center">Optimal Size should be larger '||
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
