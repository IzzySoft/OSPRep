
  PROCEDURE undostats IS
    CURSOR C_UST (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER, btime IN VARCHAR2, etime IN VARCHAR2) IS
      SELECT undotsn, endt,undob,txcnt,maxq,maxc,snol,nosp,blkst
        FROM ( SELECT undotsn,
                      to_char(end_time,'DD.MM.YYYY HH24:MI') endt,
                      to_char(undoblks,'99,999,999') undob,
                      to_char(txncount,'99,999,999') txcnt,
		      to_char(maxquerylen,'999,999,999') maxq,
		      to_char(maxconcurrency,'999,999') maxc,
		      to_char(ssolderrcnt,'99,999') snol,
		      to_char(nospaceerrcnt,'99,999') nosp,
		      unxpstealcnt||'/'||unxpblkrelcnt||'/'||
		      unxpblkreucnt||' / '||expstealcnt||'/'||
		      expblkrelcnt||'/'||expblkreucnt blkst
                 FROM stats$undostat
                WHERE dbid = db_id
                  AND instance_number = instnum
                  AND end_time > to_date(btime, 'DD.MM.YYYY HH24:MI:SS')
                  AND begin_time < to_date(etime, 'DD.MM.YYYY HH24:MI:SS')
                ORDER BY begin_time desc )
       WHERE rownum < 25;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8">Undo Segment Statistics'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'undoseg'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	        'VALIGN="middle"></A></TH></TR>';
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
      FOR R_USS IN C_UST(DBID,INST_NUM,BID,EID,BTIME,ETIME) LOOP
        L_LINE := ' <TR><TD CLASS="td_name" ALIGN="right">'||R_USS.endt||'</TD><TD ALIGN="right">'||
                  R_USS.undob||'</TD><TD ALIGN="right">'||R_USS.txcnt||
	          '</TD><TD ALIGN="right">'||R_USS.maxq||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||R_USS.maxc||'</TD><TD ALIGN="right">'||
                  R_USS.snol||'</TD><TD ALIGN="right">'||R_USS.nosp||'</TD><TD ALIGN="right">'||
	          R_USS.blkst||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

