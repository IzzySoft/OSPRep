#!/bin/bash
# =============================================================================
# Oracle StatsPack Report 2 HTML       (c) 2003 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# $Id$
# -----------------------------------------------------------------------------
# Data File Stats. This procedure is only included if the according objects
# exist in the perfstat users schema
# =============================================================================

cat>>$SQLSET<<ENDSQL
PROCEDURE get_filestats IS
 CURSOR cur IS
  SELECT b.tablespace tsname,b.datafile dfname,
         TO_CHAR(b.bytes/1024/1024,'99,999,990.0') b_bytes,
	 TO_CHAR(b.bytes_free/1024/1024,'99,999,990.0') b_freebytes,
         TO_CHAR(100*(1-(b.bytes_free/b.bytes)),'990.00') b_freepct,
	 TO_CHAR(e.bytes/1024/1024,'99,999,990.0') e_bytes,
	 TO_CHAR(e.bytes_free/1024/1024,'99,999,990.0') e_freebytes,
         TO_CHAR(100*(1-(e.bytes_free/e.bytes)),'990.00') e_freepct,
	 TO_CHAR((e.bytes - b.bytes)/1024/1024,'99,999,990.0') byte_diff,
	 TO_CHAR((100*e.bytes/b.bytes)-100,'9,990.00') pct_diff,
	 (100*e.bytes/b.bytes)-100 num_pctdiff,
	 s.minsnap min_snap,s.maxsnap max_snap
    FROM istats\$datafiles b,istats\$datafiles e,
	 ( SELECT MIN(snap_id) minsnap, MAX(snap_id) maxsnap
	     FROM istats\$datafiles
	    WHERE snap_id BETWEEN BID AND EID ) s
   WHERE b.dbid = DB_ID
     AND e.dbid = DB_ID
     AND b.instance_number = INST_NUM
     AND e.instance_number = INST_NUM
     AND b.snap_id = s.minsnap
     AND e.snap_id = s.maxsnap
     AND b.datafile = e.datafile
    ORDER BY b.tablespace,b.datafile;
 BEGIN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="filestats"></A>'||
              ' Datafiles Statistics</TH></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="10"><DIV ALIGN="center">Ordered by Tablespace, '||
              'Datafile</DIV></TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TH CLASS="th_sub">Tablespace</TH><TH CLASS="th_sub">Datafile</TH>'||
              '<TH CLASS="th_sub">BeginSize</TH><TH CLASS="th_sub">BeginFree</TH>'||
	      '<TH CLASS="th_sub">% Free</TH>';
    print(L_LINE);
    L_LINE := '<TH CLASS="th_sub">EndSize</TH><TH CLASS="th_sub">EndFree</TH>'||
              '<TH CLASS="th_sub">% Free</TH><TH CLASS="th_sub">Change</TH>'||
	      '<TH CLASS="th_sub">% Change</TH></TR>';
    print(L_LINE);
    FOR rec IN cur LOOP
      S1 := alert_gt_warn(7*rec.num_pctdiff/DB_UPTIME,AR_DF_CHNG,WR_DF_CHNG);
      L_LINE := ' <TR><TD CLASS="td_name">'||rec.tsname||'</TD><TD CLASS="td_name">'||
                rec.dfname||'</TD><TD ALIGN="right">'||rec.b_bytes||
                ' M</TD><TD ALIGN="right">'||rec.b_freebytes||' M</TD><TD ALIGN="right">';
      print(L_LINE);
      L_LINE := rec.b_freepct||'</TD><TD ALIGN="right">'||rec.e_bytes||
		' M</TD><TD ALIGN="right">'||rec.e_freebytes||' M</TD><TD ALIGN="right">'||
		rec.e_freepct||'</TD><TD ALIGN="right"'||S1||'>'||rec.byte_diff||
		' M</TD><TD ALIGN="right"'||S1||'>'||rec.pct_diff||'</TD></TR>';
      print(L_LINE);
    END LOOP;
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    print('<HR>');
 EXCEPTION
   WHEN OTHERS THEN NULL;
 END;

ENDSQL