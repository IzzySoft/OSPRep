
  PROCEDURE undosum IS
    CURSOR C_USS IS
      SELECT undotsn,
             to_char(sum(undoblks),'999,999,999,999') undob,
	     to_char(sum(txncount),'9,999,999,999,999') txcnt,
	     max(maxquerylen) maxq,
	     to_char(max(maxconcurrency),'999,999') maxc,
	     to_char(sum(ssolderrcnt),'99,999') snol,
	     to_char(sum(nospaceerrcnt),'99,999') nosp,
	     sum(unxpstealcnt)||'/'||sum(unxpblkrelcnt)||'/'||
	     sum(unxpblkreucnt)||' / '||sum(expstealcnt)||'/'||
	     sum(expblkrelcnt)||'/'||sum(expblkreucnt) blkst
        FROM stats$undostat
       WHERE dbid = DB_ID
         AND instance_number = INST_NUM
         AND end_time > to_date(BTIME, 'DD.MM.YYYY HH24:MI:SS')
         AND begin_time < to_date(ETIME, 'DD.MM.YYYY HH24:MI:SS')
       GROUP BY undotsn;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Undo Segment Summary'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'undoseg'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
	        'ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="8" ALIGN="center">Undo Segment block stats<BR>'||
                'uS - unexpired Stolen, uR - unexpired Released, uU - unexpired reUsed<BR>';
      print(L_LINE);
      L_LINE := 'eS - expired Stolen, eR - expired Released, eU - expired reUsed</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Undo TS#</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
                '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	        '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
                'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
      print(L_LINE);
      FOR R_USS IN C_USS LOOP
        L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.undotsn||'</TD><TD ALIGN="right">'||
                  R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	          '</TD><TD ALIGN="right">'||format_stime(R_USS.maxq,1)||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
                  R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	          R_USS.blkst||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE undostats IS
    CURSOR C_UST IS
      SELECT undotsn, endt,undob,txcnt,maxq,maxc,snol,nosp,blkst
        FROM ( SELECT undotsn,
                      to_char(end_time,'DD.MM.YYYY HH24:MI') endt,
                      to_char(undoblks,'99,999,999') undob,
                      to_char(txncount,'99,999,999') txcnt,
		      maxquerylen maxq,
		      to_char(maxconcurrency,'999,999') maxc,
		      to_char(ssolderrcnt,'99,999') snol,
		      to_char(nospaceerrcnt,'99,999') nosp,
		      unxpstealcnt||'/'||unxpblkrelcnt||'/'||
		      unxpblkreucnt||' / '||expstealcnt||'/'||
		      expblkrelcnt||'/'||expblkreucnt blkst
                 FROM stats$undostat
                WHERE dbid = DB_ID
                  AND instance_number = INST_NUM
                  AND end_time > to_date(BTIME, 'DD.MM.YYYY HH24:MI:SS')
                  AND begin_time < to_date(ETIME, 'DD.MM.YYYY HH24:MI:SS')
                ORDER BY begin_time desc )
       WHERE rownum < 25;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Undo Segment Statistics'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'undoseg'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
	        'ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="8" ALIGN="center">Ordered by Time desc</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">End Time</TH><TH CLASS="th_sub">Undo Blocks</TH>'||
                '<TH CLASS="th_sub"># TXN</TH><TH CLASS="th_sub">Max Qry Len (s)</TH>'||
	        '<TH CLASS="th_sub">Max Tx Concurcy</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Snapshot Too Old</TH><TH CLASS="th_sub">'||
                'Out of Space</TH><TH CLASS="th_sub">uS/ur/uU / eS/eR/eU</TH></TR>';
      print(L_LINE);
      FOR R_USS IN C_UST LOOP
        L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.endt||'</TD><TD ALIGN="right">'||
                  R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	          '</TD><TD ALIGN="right">'||format_stime(R_USS.maxq,1)||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
                  R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	          R_USS.blkst||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;
