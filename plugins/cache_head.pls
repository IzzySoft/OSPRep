
  PROCEDURE dictcache IS
    CURSOR C_CAD IS
      SELECT lower(b.parameter) param,
             to_char(e.gets - b.gets,'9,999,999,990') gets,
             nvl(to_char(decode(e.gets, b.gets, NULL,
	                   (e.getmisses - b.getmisses) *100 /
		           (e.gets - b.gets)),'990.00'),'&nbsp') getm,
             to_char(e.scans - b.scans,'9,990') scans,
	     nvl(to_char(decode(e.scans, b.scans, NULL,
	                  (e.scanmisses - b.scanmisses) *100 /
	                  (e.scans - b.scans)),'990.00'),'&nbsp;') scanm,
             to_char(e.modifications - b.modifications,'999,999,990') mods,
	     to_char(e.usage,'9,999,990') usage,
	     nvl(to_char(decode(nvl(e.total_usage,0),0,0,
	                   e.usage *100/e.total_usage),'990.00'),'&nbsp') sgapct
        FROM stats$rowcache_summary b, stats$rowcache_summary e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.instance_number = e.instance_number
         AND b.parameter       = e.parameter
         AND e.gets - b.gets   > 0
       ORDER BY param;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Dictionary Cache</TH></TR>'||
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
      FOR R_CA IN C_CAD LOOP
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE libcache IS
    CURSOR C_CAM IS
      SELECT b.namespace namespace,
             to_char(e.gets - b.gets,'999,999,990') gets,
             nvl(to_char(decode(e.gets,b.gets,NULL,
	                  100 - (e.gethits - b.gethits) * 100 /
	                  (e.gets - b.gets)),'990.00'),'&nbsp;') getm,
             decode(e.gets,b.gets,NULL,
                          100 - (e.gethits - b.gethits) * 100 /
	                  (e.gets - b.gets)) ngetm,
             to_char(e.pins - b.pins,'9,999,999,990') pins,
	     nvl(to_char(decode(e.pins,b.pins,NULL,
	                  100 - (e.pinhits - b.pinhits) *100 /
	                  (e.pins - b.pins)),'990.00'),'&nbsp;') pinm,
             to_char(e.reloads - b.reloads,'9,999,990') reloads,
	     to_char(e.invalidations - b.invalidations,'999,999,990') inv,
	     decode(e.gets,b.gets,NULL,
	            (e.reloads - b.reloads) / (e.gets - b.gets)) rpg,
             decode(e.gets,b.gets,NULL,
	            (e.invalidations - b.invalidations) / (e.gets - b.gets)) ipg
        FROM stats$librarycache b, stats$librarycache e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.dbid    = e.dbid
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.instance_number = e.instance_number
         AND b.namespace       = e.namespace
         AND e.gets - b.gets   > 0
       ORDER BY namespace;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7">Library Cache'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'libcache'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" VALIGN="middle"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="7" ALIGN="center">"Pct Misses" should '||
                'be very low (&lt; 10%), "Reloads" should not be significantly high.</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">NameSpace</TH><TH CLASS="th_sub">Get Requests</TH>'||
                '<TH CLASS="th_sub">Pct Miss</TH><TH CLASS="th_sub">Pin Reqs</TH>'||
	        '<TH CLASS="th_sub">Pct Miss</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Reloads</TH><TH CLASS="th_sub">Invalidations</TH></TR>';
      print(L_LINE);
      FOR R_CA IN C_CAM LOOP
        S1 := alert_gt_warn(R_CA.ngetm,AR_LC_MISS,WR_LC_MISS);
        S2 := alert_gt_warn(R_CA.rpg,AR_LC_RLPRQ,WR_LC_RLPRQ);
        S3 := alert_gt_warn(R_CA.ipg,AR_LC_INVPRQ,WR_LC_INVPRQ);
        L_LINE := ' <TR><TD CLASS="td_name">'||R_CA.namespace||'</TD><TD ALIGN="right">'||
                  R_CA.gets||'</TD><TD ALIGN="right"'||S1||'>'||R_CA.getm||
                  '</TD><TD ALIGN="right">'||R_CA.pins||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_CA.pinm||'</TD><TD ALIGN="right"'||S2||'>'||
                  R_CA.reloads||'</TD><TD ALIGN="right"'||S3||'>'||R_CA.inv||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
