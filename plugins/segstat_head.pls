
  PROCEDURE seg_lr IS
    CURSOR C_SegStat IS
      SELECT n.owner,n.tablespace_name,n.object_name,
             case when length(n.subobject_name) < 11
	          then n.subobject_name
		  else substr(n.subobject_name,length(n.subobject_name)-9)
	     end subobject_name,
             n.object_type,to_char(r.logical_reads,'999,999,999') logical_reads,
             to_char(round(r.ratio * 100, 2),'990.00') ratio
        FROM stats$seg_stat_obj n,
             ( SELECT * FROM
               ( SELECT e.dataobj#,e.obj#,e.dbid,
                        e.logical_reads - nvl(b.logical_reads,0) logical_reads,
                        ratio_to_report(e.logical_reads - nvl(b.logical_reads,0)) over () ratio
                   FROM stats$seg_stat e,stats$seg_stat b
                  WHERE b.snap_id(+) = BID
                    AND e.snap_id    = EID
                    AND b.dbid(+)    = DB_ID
                    AND e.dbid       = DB_ID
                    AND b.instance_number(+) = INST_NUM
                    AND e.instance_number = INST_NUM
                    AND e.obj#       = b.obj#(+)
                    AND e.dataobj#   = b.dataobj#(+)
                    AND e.logical_reads - nvl(b.logical_reads, 0)  > 0
                  ORDER BY logical_reads desc ) d
                 WHERE rownum <= TOP_N_SEGSTAT) r
       WHERE n.dataobj# = r.dataobj#
         AND n.obj#     = r.obj#
         AND n.dbid     = r.dbid;
    BEGIN
      print(TABLE_OPEN||'<TR><TH COLSPAN="5">Top '||TOP_N_SEGSTAT||' Logical Reads per Segment</TH></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Object</TH>'||
                '<TH CLASS="th_sub">Type</TH><TH CLASS="th_sub">LogReads</TH>'||
                '<TH CLASS="th_sub">Ratio</TH></TR>';
      print(L_LINE);
      FOR RS in C_SegStat LOOP
        L_LINE := ' <TR><TD>'||RS.tablespace_name||'</TD><TD>'||RS.owner||'.'||
                  RS.object_name;
        IF RS.subobject_name IS NOT NULL THEN
          L_LINE := L_LINE||'.'||RS.subobject_name;
        END IF;
        L_LINE := L_LINE||'</TD><TD>'||RS.object_type||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||RS.logical_reads||'</TD><TD ALIGN="right">'||
                  RS.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE seg_pr IS
    CURSOR C_SegStat IS
      SELECT n.owner,n.tablespace_name,n.object_name,
             case when length(n.subobject_name) < 11
	          then n.subobject_name
		  else substr(n.subobject_name,length(n.subobject_name)-9)
	     end subobject_name,
             n.object_type,to_char(r.physical_reads,'999,999,999') physical_reads,
             to_char(round(r.ratio * 100, 2),'990.00') ratio
        FROM stats$seg_stat_obj n,
             ( SELECT * FROM
               ( SELECT e.dataobj#,e.obj#,e.dbid,
                        e.physical_reads - nvl(b.physical_reads,0) physical_reads,
                        ratio_to_report(e.physical_reads - nvl(b.physical_reads,0)) over () ratio
                   FROM stats$seg_stat e,stats$seg_stat b
                  WHERE b.snap_id(+) = BID
                    AND e.snap_id    = EID
                    AND b.dbid(+)    = DB_ID
                    AND e.dbid       = DB_ID
                    AND b.instance_number(+) = INST_NUM
                    AND e.instance_number = INST_NUM
                    AND e.obj#       = b.obj#(+)
                    AND e.dataobj#   = b.dataobj#(+)
                    AND e.physical_reads - nvl(b.physical_reads, 0)  > 0
                  ORDER BY physical_reads desc ) d
                 WHERE rownum <= TOP_N_SEGSTAT) r
       WHERE n.dataobj# = r.dataobj#
         AND n.obj#     = r.obj#
         AND n.dbid     = r.dbid;
    BEGIN
      print(TABLE_OPEN||'<TR><TH COLSPAN="5">Top '||TOP_N_SEGSTAT||' Physical Reads per Segment</TH></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Object</TH>'||
                '<TH CLASS="th_sub">Type</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">PhyReads</TH>'||
                '<TH CLASS="th_sub">Ratio</TH></TR>';
      print(L_LINE);
      FOR RS in C_SegStat LOOP
        L_LINE := ' <TR><TD>'||RS.tablespace_name||'</TD><TD>'||RS.owner||'.'||
                  RS.object_name;
        IF RS.subobject_name IS NOT NULL THEN
          L_LINE := L_LINE||'.'||RS.subobject_name;
        END IF;
        print(L_LINE);
        L_LINE := '</TD><TD>'||RS.object_type||'</TD>'||'<TD ALIGN="right">'||
                  RS.physical_reads||'</TD><TD ALIGN="right">'||RS.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE seg_bw IS
    CURSOR C_SegStat IS
      SELECT n.owner,n.tablespace_name,n.object_name,
             case when length(n.subobject_name) < 11
	          then n.subobject_name
		  else substr(n.subobject_name,length(n.subobject_name)-9)
	     end subobject_name,
             n.object_type,to_char(r.waits,'999,999,999') waits,
             to_char(round(r.ratio * 100, 2),'990.00') ratio
        FROM stats$seg_stat_obj n,
             ( SELECT * FROM
               ( SELECT e.dataobj#,e.obj#,e.dbid,
                        e.buffer_busy_waits - nvl(b.buffer_busy_waits,0) waits,
                        ratio_to_report(e.buffer_busy_waits - nvl(b.buffer_busy_waits,0)) over () ratio
                   FROM stats$seg_stat e,stats$seg_stat b
                  WHERE b.snap_id(+) = BID
                    AND e.snap_id    = EID
                    AND b.dbid(+)    = DB_ID
                    AND e.dbid       = DB_ID
                    AND b.instance_number(+) = INST_NUM
                    AND e.instance_number = INST_NUM
                    AND e.obj#       = b.obj#(+)
                    AND e.dataobj#   = b.dataobj#(+)
                    AND e.buffer_busy_waits - nvl(b.buffer_busy_waits, 0)  > 0
                  ORDER BY waits desc ) d
                 WHERE rownum <= TOP_N_SEGSTAT) r
       WHERE n.dataobj# = r.dataobj#
         AND n.obj#     = r.obj#
         AND n.dbid     = r.dbid;
    BEGIN
      print(TABLE_OPEN||'<TR><TH COLSPAN="5">Top '||TOP_N_SEGSTAT||' Buffer Busy Waits per Segment</TH></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Object</TH>'||
                '<TH CLASS="th_sub">Type</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">Ratio</TH></TR>';
      print(L_LINE);
      FOR RS in C_SegStat LOOP
        L_LINE := ' <TR><TD>'||RS.tablespace_name||'</TD><TD>'||RS.owner||'.'||
                  RS.object_name;
        IF RS.subobject_name IS NOT NULL THEN
          L_LINE := L_LINE||'.'||RS.subobject_name;
        END IF;
        print(L_LINE);
        L_LINE := '</TD><TD>'||RS.object_type||'</TD>'||'<TD ALIGN="right">'||
                  RS.waits||'</TD><TD ALIGN="right">'||RS.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE seg_lw IS
    CURSOR C_SegStat IS
      SELECT n.owner,n.tablespace_name,n.object_name,
             case when length(n.subobject_name) < 11
	          then n.subobject_name
		  else substr(n.subobject_name,length(n.subobject_name)-9)
	     end subobject_name,
             n.object_type,to_char(r.waits,'999,999,999') waits,
             to_char(round(r.ratio * 100, 2),'990.00') ratio
        FROM stats$seg_stat_obj n,
             ( SELECT * FROM
               ( SELECT e.dataobj#,e.obj#,e.dbid,
                        e.row_lock_waits - nvl(b.row_lock_waits,0) waits,
                        ratio_to_report(e.row_lock_waits - nvl(b.row_lock_waits,0)) over () ratio
                   FROM stats$seg_stat e,stats$seg_stat b
                  WHERE b.snap_id(+) = BID
                    AND e.snap_id    = EID
                    AND b.dbid(+)    = DB_ID
                    AND e.dbid       = DB_ID
                    AND b.instance_number(+) = INST_NUM
                    AND e.instance_number = INST_NUM
                    AND e.obj#       = b.obj#(+)
                    AND e.dataobj#   = b.dataobj#(+)
                    AND e.row_lock_waits - nvl(b.row_lock_waits, 0)  > 0
                  ORDER BY waits desc ) d
                 WHERE rownum <= TOP_N_SEGSTAT) r
       WHERE n.dataobj# = r.dataobj#
         AND n.obj#     = r.obj#
         AND n.dbid     = r.dbid;
    BEGIN
      print(TABLE_OPEN||'<TR><TH COLSPAN="5">Top '||TOP_N_SEGSTAT||' Row Lock Waits per Segment</TH></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">Object</TH>'||
                '<TH CLASS="th_sub">Type</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">Ratio</TH></TR>';
      print(L_LINE);
      FOR RS in C_SegStat LOOP
        L_LINE := ' <TR><TD>'||RS.tablespace_name||'</TD><TD>'||RS.owner||'.'||
                  RS.object_name;
        IF RS.subobject_name IS NOT NULL THEN
          L_LINE := L_LINE||'.'||RS.subobject_name;
        END IF;
        print(L_LINE);
        L_LINE := '</TD><TD>'||RS.object_type||'</TD>'||'<TD ALIGN="right">'||
                  RS.waits||'</TD><TD ALIGN="right">'||RS.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;
