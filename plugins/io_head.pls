
  PROCEDURE tsio IS
    RDSIZ VARCHAR2(100); WRTSIZ VARCHAR2(100);
    CURSOR C_TSIO IS
      SELECT e.tsname tsname,
             to_char(sum(e.phyrds - nvl(b.phyrds,0)),'9,999,999,990') reads,
             to_char(sum(e.phyrds - nvl(b.phyrds,0))/ELA,'9,990.00') rps,
	     to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10),
		   '999,990.0') avgrd,
             decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10) avems,
             to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
             decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ) bprn,
             to_char(sum(e.phywrts - nvl(b.phywrts,0)),'9,999,999,990') writes,
	     to_char(sum(e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
             to_char(sum(e.wait_count - nvl(b.wait_count,0)),'999,999,999,990') waits,
	     to_char(decode(sum(e.wait_count - nvl(b.wait_count,0)),
	           0,0,
		   (sum(e.time - nvl(b.time,0)) /
		    sum(e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
             sum(e.phywrts - nvl(b.phywrts,0)) +
	     sum(e.phyrds - nvl(b.phyrds,0)) ios,
             sum(e.phyblkrd - nvl(b.phyblkrd,0))*DB_BLOCKSIZE bread,
             sum(e.phyblkwrt - nvl(b.phyblkwrt,0))*DB_BLOCKSIZE bwrite
        FROM stats$filestatxs e, stats$filestatxs b
       WHERE b.snap_id(+) = BID
         AND e.snap_id    = EID
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.tsname(+)  = e.tsname
         AND b.filename(+)= e.filename
         AND ( (e.phyrds - nvl(b.phyrds,0) ) +
               (e.phywrts - nvl(b.phywrts,0) ) ) > 0
       GROUP BY e.tsname
      UNION SELECT e.tsname tsname,
             to_char(sum(e.phyrds - nvl(b.phyrds,0)),'9,999,999,990') reads,
             to_char(sum(e.phyrds - nvl(b.phyrds,0))/ela,'9,990.00') rps,
	     to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10),
		   '999,990.0') avgrd,
             decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0,0,
	           (sum(e.readtim - nvl(b.readtim,0)) / sum(e.phyrds - nvl(b.phyrds,0))) * 10) avems,
             to_char(decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
             decode(sum(e.phyrds - nvl(b.phyrds,0)),
	           0, to_number(NULL),
		   sum(e.phyblkrd - nvl(b.phyblkrd,0)) /
		   sum(e.phyrds - nvl(b.phyrds,0)) ) bprn,
             to_char(sum(e.phywrts - nvl(b.phywrts,0)),'9,999,999,990') writes,
	     to_char(sum(e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
             to_char(sum(e.wait_count - nvl(b.wait_count,0)),'999,999,999,990') waits,
	     to_char(decode(sum(e.wait_count - nvl(b.wait_count,0)),
	           0,0,
		   (sum(e.time - nvl(b.time,0)) /
		    sum(e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
             sum(e.phywrts - nvl(b.phywrts,0)) +
	     sum(e.phyrds - nvl(b.phyrds,0)) ios,
             sum(e.phyblkrd - nvl(b.phyblkrd,0))*DB_BLOCKSIZE bread,
             sum(e.phyblkwrt - nvl(b.phyblkwrt,0))*DB_BLOCKSIZE bwrite
        FROM stats$tempstatxs e, stats$tempstatxs b
       WHERE b.snap_id(+) = bid
         AND e.snap_id    = eid
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.tsname(+)  = e.tsname
         AND b.filename(+)= e.filename
         AND ( (e.phyrds - nvl(b.phyrds,0) ) +
               (e.phywrts - nvl(b.phywrts,0) ) ) > 0
       GROUP BY e.tsname
       ORDER BY ios desc;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="11">TableSpace IO Summary Statistics'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'fileio'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="11" ALIGN="center">Ordered by IOs (Reads + Writes)'||
                ' desc<BR>ReadSize/WriteSize report the physical IO Size</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Reads</TH>'||
                '<TH CLASS="th_sub">AvgReads/s</TH><TH CLASS="th_sub">AvgRd (ms)</TH>'||
	        '<TH CLASS="th_sub">Avg Blks/Rd</TH>';
      print(L_LINE);
      L_LINE:= '<TH CLASS="th_sub">Writes</TH><TH CLASS="th_sub">Avg Wrt/s</TH>'||
               '<TH CLASS="th_sub">ReadSize</TH><TH CLASS="th_sub">WriteSize</TH>'||
               '<TH CLASS="th_sub">Buffer Waits</TH><TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
      print(L_LINE);
      FOR R_TSIO IN C_TSIO LOOP
        RDSIZ  := format_fsize(R_TSIO.bread);
        WRTSIZ := format_fsize(R_TSIO.bwrite);
        S1 := alert_gt_warn(R_TSIO.bprn,I1*AR_TS_BLKRD/100,I1*WR_TS_BLKRD/100);
        S2 := alert_gt_warn(R_TSIO.avems,AR_TS_RD,WR_TS_RD);
        L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.tsname||'</TD><TD ALIGN="right">'||
                  R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
	          '</TD><TD ALIGN="right"'||S2||'>'||R_TSIO.avgrd;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right"'||S1||'>'||R_TSIO.bpr||
                  '</TD><TD ALIGN="right">'||R_TSIO.writes||'</TD><TD ALIGN="right">'||
	          R_TSIO.wps||'</TD><TD ALIGN="right">'||RDSIZ||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||WRTSIZ||'</TD>'||
                  '<TD ALIGN="right">'||R_TSIO.waits||
                  '</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE fio IS
    RDSIZ VARCHAR2(100); WRTSIZ VARCHAR2(100);
    CURSOR C_FileIO IS
      SELECT e.tsname ts_name,
             e.filename file_name,
             to_char(e.phyrds - nvl(b.phyrds,0),'9,999,999,990') reads,
	     to_char((e.phyrds - nvl(b.phyrds,0))/ELA,'9,990.00') rps,
	     to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / 
		    (e.phyrds - nvl(b.phyrds,0))) * 10),
		   '999,990.0') avgrd,
             decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / 
		    (e.phyrds - nvl(b.phyrds,0))) * 10) avems,
             to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
             decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ) bprn,
             to_char(e.phywrts - nvl(b.phywrts,0),'9,999,999,990') writes,
	     to_char((e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
             to_char(e.wait_count - nvl(b.wait_count,0),'999,999,990') waits,
	     to_char(decode(e.wait_count - nvl(b.wait_count,0),
	           0,0,
		   ((e.time - nvl(b.time,0)) /
		    (e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
             (e.phyblkrd - nvl(b.phyblkrd,0))*DB_BLOCKSIZE bread,
             (e.phyblkwrt - nvl(b.phyblkwrt,0))*DB_BLOCKSIZE bwrite
        FROM stats$filestatxs e, stats$filestatxs b
       WHERE b.snap_id(+) = BID
         AND e.snap_id    = EID
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.tsname(+)  = e.tsname
         AND b.filename(+)= e.filename
         AND ( (e.phyrds - nvl(b.phyrds,0) ) +
               (e.phywrts - nvl(b.phywrts,0) ) ) > 0
      UNION SELECT e.tsname ts_name,
             e.filename file_name,
             to_char(e.phyrds - nvl(b.phyrds,0),'9,999,999,990') reads,
             to_char((e.phyrds - nvl(b.phyrds,0))/ELA,'9,990.00') rps,
	     to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / (e.phyrds - nvl(b.phyrds,0))) * 10),
		   '999,990.0') avgrd,
             decode(e.phyrds - nvl(b.phyrds,0),
	           0,0,
	           ((e.readtim - nvl(b.readtim,0)) / 
		    (e.phyrds - nvl(b.phyrds,0))) * 10) avems,
             to_char(decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ), '9,990.0') bpr,
             decode(e.phyrds - nvl(b.phyrds,0),
	           0, to_number(NULL),
		   (e.phyblkrd - nvl(b.phyblkrd,0)) /
		   (e.phyrds - nvl(b.phyrds,0)) ) bprn,
             to_char(e.phywrts - nvl(b.phywrts,0),'9,999,999,990') writes,
	     to_char((e.phywrts - nvl(b.phywrts,0))/ela,'9,990.00') wps,
             to_char(e.wait_count - nvl(b.wait_count,0),'999,999,990') waits,
	     to_char(decode(e.wait_count - nvl(b.wait_count,0),
	           0,0,
		   ((e.time - nvl(b.time,0)) /
		    (e.wait_count - nvl(b.wait_count,0)))*10),
		   '9,990.0') avgbw,
             (e.phyblkrd - nvl(b.phyblkrd,0))*DB_BLOCKSIZE bread,
             (e.phyblkwrt - nvl(b.phyblkwrt,0))*DB_BLOCKSIZE bwrite
        FROM stats$tempstatxs e, stats$tempstatxs b
       WHERE b.snap_id(+) = BID
         AND e.snap_id    = EID
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.dbid(+)    = e.dbid
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
         AND b.instance_number(+) = e.instance_number
         AND b.tsname(+)  = e.tsname
         AND b.filename(+)= e.filename
         AND ( (e.phyrds - nvl(b.phyrds,0) ) +
               (e.phywrts - nvl(b.phywrts,0) ) ) > 0
       ORDER BY ts_name,file_name;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="12">File IO Summary Statistics'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'fileio'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="12" ALIGN="center">Ordered by TableSpace, File'||
                '<BR>ReadSize/WriteSize report the physical IO Size</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Filename</TH>'||
                '<TH CLASS="th_sub">Reads</TH><TH CLASS="th_sub">Avg Reads/s</TH>'||
	        '<TH CLASS="th_sub">AvgRd (ms)</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Avg Blks/Rd</TH><TH CLASS="th_sub">Writes</TH>'||
                '<TH CLASS="th_sub">Avg Wrt/s</TH><TH CLASS="th_sub">Read Size</TH>'||
                '<TH CLASS="th_sub">Write Size</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Buffer Waits</TH>'||
	        '<TH CLASS="th_sub">Avg Buf Wt (ms)</TH></TR>';
      print(L_LINE);
      FOR R_TSIO IN C_FileIO LOOP
        RDSIZ  := format_fsize(R_TSIO.bread);
        WRTSIZ := format_fsize(R_TSIO.bwrite);
        S1 := alert_gt_warn(R_TSIO.bprn,I1*AR_TS_BLKRD/100,I1*WR_TS_BLKRD/100);
        S2 := alert_gt_warn(R_TSIO.avems,AR_TS_RD,WR_TS_RD);
        L_LINE := ' <TR><TD CLASS="td_name">'||R_TSIO.ts_name||'</TD><TD CLASS="td_name">'||
                  R_TSIO.file_name||'</TD><TD ALIGN="right">'||
                  R_TSIO.reads||'</TD><TD ALIGN="right">'||R_TSIO.rps||
                  '</TD><TD ALIGN="right"'||S2||'>'||R_TSIO.avgrd;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right"'||S1||'>'||R_TSIO.bpr||'</TD><TD ALIGN="right">'||
                  R_TSIO.writes||'</TD><TD ALIGN="right">'||R_TSIO.wps||
                  '</TD><TD ALIGN="right">'||RDSIZ||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||WRTSIZ||'</TD><TD ALIGN="right">'||
	          R_TSIO.waits||'</TD><TD ALIGN="right">'||R_TSIO.avgbw||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
--      WHEN OTHERS THEN NULL;
      WHEN OTHERS THEN
        print(TABLE_CLOSE);
    END;
