
  PROCEDURE reco IS
    CURSOR C_Recover IS
      SELECT 'B' name,
             target_mttr tm,
             estimated_mttr em,
	     to_char(recovery_estimated_ios,'9,999,999') rei,
             to_char(actual_redo_blks,'99,999,999') arb,
	     to_char(target_redo_blks,'99,999,999') trb,
             to_char(log_file_size_redo_blks,'99,999,999') lfrb,
	     nvl(to_char(log_chkpt_timeout_redo_blks,'99,999,999'),'&nbsp;') lctrb,
             nvl(to_char(log_chkpt_interval_redo_blks,'99,999,999,999'),'&nbsp;') lcirb,
	     snap_id snid
        FROM stats$instance_recovery b
       WHERE b.snap_id = BID
         AND b.dbid    = DB_ID
         AND b.instance_number = INST_NUM
      UNION SELECT 'E' name,
             target_mttr tm,
             estimated_mttr em,
	     to_char(recovery_estimated_ios,'9,999,999') rei,
             to_char(actual_redo_blks,'99,999,999') arb,
	     to_char(target_redo_blks,'99,999,999') trb,
             to_char(log_file_size_redo_blks,'99,999,999') lfrb,
	     nvl(to_char(log_chkpt_timeout_redo_blks,'99,999,999'),'&nbsp;') lctrb,
             nvl(to_char(log_chkpt_interval_redo_blks,'99,999,999,999'),'&nbsp;') lcirb,
	     snap_id snid
        FROM stats$instance_recovery e
       WHERE e.snap_id = EID
         AND e.dbid    = DB_ID
         AND e.instance_number = INST_NUM
       ORDER BY snid;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="recover">Instance Recovery Statistics</A></TH></TR>'||
                ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Target MTTR</TH>'||
                '<TH CLASS="th_sub">Estd MTTR</TH><TH CLASS="th_sub">Recovery Estd IOs</TH>'||
	        '<TH CLASS="th_sub">Actual Redo Blks</TH>';
      print(L_LINE);
      L_LINE:= '<TH CLASS="th_sub">Target Redo Blks</TH><TH CLASS="th_sub">LogFile Size Redo Blks</TH>'||
               '<TH CLASS="th_sub">Log Ckpt Timeout Redo Blks</TH>'||
	       '<TH CLASS="th_sub">Log Ckpt Interval Redo Blks</TH></TR>';
      print(L_LINE);
      FOR R_Reco IN C_Recover LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_Reco.name||'</TD><TD ALIGN="right">'||
                  format_stime(R_Reco.tm,1)||'</TD><TD ALIGN="right">'||format_stime(R_Reco.em,1)||
	          '</TD><TD ALIGN="right">'||R_Reco.rei||'</TD><TD ALIGN="right">'||
	          R_Reco.arb||'</TD><TD ALIGN="right">';
        print(L_LINE);
        L_LINE := R_Reco.trb||'</TD><TD ALIGN="right">'||R_Reco.lfrb||
                  '</TD><TD ALIGN="right">'||R_Reco.lctrb||'</TD><TD ALIGN="right">'||
	          R_Reco.lcirb||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

