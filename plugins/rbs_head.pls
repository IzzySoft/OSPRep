
  PROCEDURE rbs_stat IS
    WRT VARCHAR2(10);
    CURSOR C_RBS IS
      SELECT b.usn rbs#,
             to_char(e.gets - b.gets,'9,999,999,990.0') gets,
             to_char(to_number(decode(e.gets,b.gets,NULL,
	          (e.waits - b.waits) * 100 / (e.gets - b.gets) )),
		  '990.00') waits,
	     ABS(e.writes - b.writes) writes,
             to_char(e.wraps - b.wraps,'999,999') wraps,
	     to_char(e.shrinks - b.shrinks,'999,999') shrinks,
             to_char(e.extends - b.extends,'999,999') extends
        FROM stats$rollstat b, stats$rollstat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
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
      FOR R_RBS IN C_RBS LOOP
        WRT := format_fsize(R_RBS.writes);
        L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
                  R_RBS.gets||'</TD><TD ALIGN="right">'||R_RBS.waits||
	          '</TD><TD ALIGN="right">'||WRT||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_RBS.wraps||'</TD><TD ALIGN="right">'||
                  R_RBS.shrinks||'</TD><TD ALIGN="right">'||R_RBS.extends||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE rbs_stor IS
    RSSIZ VARCHAR2(10); OSIZ VARCHAR2(10); MSIZ VARCHAR2(10); AVESIZ VARCHAR2(10);
    CURSOR C_RBST IS
      SELECT b.usn rbs#,
             e.rssize rssize,
             e.aveactive active,
	     to_number(decode(e.optsize,-4096,NULL,e.optsize)) optsize,
             e.hwmsize hwmsize
        FROM stats$rollstat b, stats$rollstat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
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
                'than Avg Active<BR>Values are taken from the End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">RBS#</TH><TH CLASS="th_sub">Segment Size</TH>'||
                '<TH CLASS="th_sub">Avg Active</TH><TH CLASS="th_sub">Optimal Size</TH>'||
	        '<TH CLASS="th_sub">Maximum Size</TH></TR>';
      print(L_LINE);
      FOR R_RBS IN C_RBST LOOP
        RSSIZ  := format_fsize(R_RBS.rssize);
        OSIZ   := format_fsize(R_RBS.optsize);
        MSIZ   := format_fsize(R_RBS.hwmsize);
        AVESIZ := format_fsize(R_RBS.active);
        L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_RBS.rbs#||'</TD><TD ALIGN="right">'||
                  RSSIZ||'</TD><TD ALIGN="right">'||AVESIZ||
	          '</TD><TD ALIGN="right">'||OSIZ||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||MSIZ||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;
