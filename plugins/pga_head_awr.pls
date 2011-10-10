
  PROCEDURE pgaa IS
    /** PGA Aggreg Target Memory Statistics */
    PAT VARCHAR2(10); PTOT VARCHAR2(10); WAUSED VARCHAR2(10); OPR VARCHAR2(10);
    CURSOR C_PGAA IS
      SELECT 'B' snap,
             to_number(p.value) pgaat,
             mu.PGA_inuse       tot_pga_used,
             (mu.PGA_used_auto + mu.PGA_used_man)  tot_tun_used,
             mu.onepr           onepr,
             DECODE(s.opt_pct,NULL,'&nbsp;',TO_CHAR(s.opt_pct,'990.00')||'%') opt_pct,
             to_char(100*(mu.PGA_inuse - mu.PGA_used_auto
                - mu.PGA_used_man)/ PGA_inuse,'990.00')    pct_unt,
             to_char(100* mu.PGA_used_auto / PGA_inuse,'990.00') pct_auto_tun,
             to_char(100* mu.PGA_used_man  / PGA_inuse,'990.00') pct_man_tun
        FROM ( SELECT sum(case when name like 'total PGA inuse%'
                             then value else 0 end)             PGA_inuse,
                      sum(case when name like 'total PGA used for auto%'
                             then value else 0 end)             PGA_used_auto,
                      sum(case when name like 'total PGA used for manual%'
                             then value else 0 end)             PGA_used_man,
                      sum(case when name like 'maximum % one-pass'
                             then value else 0 end)             onepr
                 FROM stats$pgastat pga
                WHERE pga.snap_id = BID
                  AND pga.dbid    = DB_ID
                  AND pga.instance_number = INST_NUM ) mu,
             ( SELECT DECODE(NVL(a.sval,0),0,NULL,100*b.oval/a.sval) opt_pct
                 FROM ( SELECT SUM(NVL(value,0)) sval 
                          FROM stats$sysstat
                         WHERE name IN ('workarea executions - optimal',
                                        'workarea executions - onepass',
                                        'workarea executions - multipass')
                           AND snap_id = bid) a,
                      ( SELECT SUM(NVL(value,0)) oval
                          FROM stats$sysstat
                         WHERE name = 'workarea executions - optimal'
                           AND snap_id = BID) b )              s,
             stats$parameter p
       WHERE p.snap_id = BID
         AND p.dbid    = DB_ID
         AND p.instance_number = INST_NUM
         AND p.name    = 'pga_aggregate_target'
      UNION SELECT 'E' snap,
             to_number(p.value) pgaat,
             mu.PGA_inuse       tot_pga_used,
             (mu.PGA_used_auto + mu.PGA_used_man)  tot_tun_used,
             mu.onepr           onepr,
             DECODE(s.opt_pct,NULL,'&nbsp;',TO_CHAR(s.opt_pct,'990.00')||'%') opt_pct,
             to_char(100*(mu.PGA_inuse - mu.PGA_used_auto
                    - mu.PGA_used_man)/ PGA_inuse,'990.00')    pct_unt,
             to_char(100* mu.PGA_used_auto / PGA_inuse,'990.00') pct_auto_tun,
             to_char(100* mu.PGA_used_man  / PGA_inuse,'990.00') pct_man_tun
        FROM ( SELECT sum(case when name like 'total PGA inuse%'
                             then value else 0 end)             PGA_inuse,
                      sum(case when name like 'total PGA used for auto%'
                             then value else 0 end)             PGA_used_auto,
                      sum(case when name like 'total PGA used for manual%'
                             then value else 0 end)             PGA_used_man,
                      sum(case when name like 'maximum % one-pass'
                             then value else 0 end)             onepr
                 FROM stats$pgastat pga
                WHERE pga.snap_id = EID
                  AND pga.dbid    = DB_ID
                  AND pga.instance_number = INST_NUM ) mu,
             ( SELECT DECODE(NVL(a.sval,0),0,NULL,100*b.oval/a.sval) opt_pct
                 FROM ( SELECT SUM(NVL(value,0)) sval 
                          FROM stats$sysstat
                         WHERE name IN ('workarea executions - optimal',
                                        'workarea executions - onepass',
                                        'workarea executions - multipass')
                           AND snap_id = EID) a,
                      ( SELECT SUM(NVL(value,0)) oval
                          FROM stats$sysstat
                         WHERE name = 'workarea executions - optimal'
                           AND snap_id = EID) b )              s,
             stats$parameter p
       WHERE p.snap_id = EID
         AND p.dbid    = DB_ID
         AND p.instance_number = INST_NUM
         AND p.name    = 'pga_aggregate_target';
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9">PGA Aggreg Target Memory Statistics</TH></TR>'||
                ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">PGA Aggreg Target</TH>'||
                '<TH CLASS="th_sub">PGA in Use</TH><TH CLASS="th_sub">W/A PGA in Use</TH>'||
                '<TH CLASS="th_sub">1-Pass Mem Req</TH>';
      print(L_LINE);
      L_LINE:= '<TH CLASS="th_sub">Optim W/A Execs</TH><TH CLASS="th_sub">Non-W/A PGA Memory</TH>'||
               '<TH CLASS="th_sub">Auto W/A PGA Mem</TH>'||
               '<TH CLASS="th_sub">Manual W/A PGA Mem</TH></TR>';
      print(L_LINE);
      FOR R_PGAA IN C_PGAA LOOP
        PAT    := format_fsize(R_PGAA.pgaat);
        PTOT   := format_fsize(R_PGAA.tot_pga_used);
        WAUSED := format_fsize(R_PGAA.tot_tun_used);
        OPR    := format_fsize(R_PGAA.onepr);
        L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAA.snap||'</TD><TD ALIGN="right">'||
                  PAT||'</TD><TD ALIGN="right">'||PTOT||
                  '</TD><TD ALIGN="right">'||WAUSED;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right">'||OPR||'</TD><TD ALIGN="right">'||
                  R_PGAA.opt_pct||'</TD><TD ALIGN="right">'||R_PGAA.pct_unt||
                  '%</TD><TD ALIGN="right">'||R_PGAA.pct_auto_tun||
                  '%</TD><TD ALIGN="right">'||R_PGAA.pct_man_tun||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN
        print(TABLE_CLOSE);
    END;

  PROCEDURE pgat IS
    /** PGA Target Advice */
    TARGUM VARCHAR2(30); EXTRABYTE VARCHAR2(30); FACTOR VARCHAR2(20);
    CURSOR C_PGAT IS
      SELECT pga_target_for_estimate target,
             pga_target_factor factor,
             estd_extra_bytes_rw extra_rw,
             estd_pga_cache_hit_percentage hits,
             estd_overalloc_count overalloc
        FROM dba_hist_pga_target_advice
       WHERE snap_id = EID
         AND dbid = DB_ID
         AND instance_number = INST_NUM
       ORDER BY pga_target_factor;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">PGA Aggreg Target Advice</TH></TR>'||
                ' <TR><TD COLSPAN="9" ALIGN="center">At the end of the reports interval (SnapShot '||EID||')</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub" TITLE="Value used for this estimation">Estimate Target</TH><TH CLASS="th_sub" TITLE="Size factor based on current setting">Factor</TH>'||
                '<TH CLASS="th_sub" TITLE="Estimated extra bytes to process">Extra Bytes</TH><TH CLASS="th_sub" TITLE="Estimated Cache-Hit Ratio">Cache-Hit%</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub" TITLE="Estimated Over-Allocation Count">OverAlloc</TH></TR>';
      print(L_LINE);
      FOR rec IN C_PGAT LOOP
        TARGUM := format_fsize(rec.target);
        EXTRABYTE := format_fsize(rec.extra_rw);
        FACTOR := TO_CHAR(rec.factor,'99.999');
        L_LINE := ' <TR><TD ALIGN="right">'||TARGUM||'</TD><TD ALIGN="right">'||FACTOR||'</TD><TD ALIGN="right">'||EXTRABYTE||'</TD><TD ALIGN="right">'||rec.hits||'</TD><TD ALIGN="right">'||rec.overalloc||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN
        print(TABLE_CLOSE);
    END;

  PROCEDURE pgam IS
    /** PGA Memory Statistics */
    SN1 VARCHAR2(10); SN2 VARCHAR2(10);
    CURSOR C_PGAM IS
      SELECT b.name  st,
             b.value snap1,
             e.value snap2,
             DECODE(b.value,0,'&nbsp;',
             TO_CHAR(100*((e.value - nvl(b.value,0))/b.value),
                        '9,999,999,990.00')||'%') diff
        FROM stats$pgastat b, stats$pgastat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.name    = e.name
         AND e.value  >= b.value
         AND e.value  >  0
      UNION SELECT b.name st,
             b.value snap1,
             e.value snap2,
             to_char(decode(b.value,0,100* (e.value - nvl(b.value,0)),
                                    100*((e.value - nvl(b.value,0))/b.value)),
                   '9,999,999,990.00')||'%' diff
        FROM stats$sysstat b, stats$sysstat e
       WHERE b.snap_id = BID
         AND e.snap_id = EID
         AND b.dbid    = DB_ID
         AND e.dbid    = DB_ID
         AND b.instance_number = INST_NUM
         AND e.instance_number = INST_NUM
         AND b.name    = e.name
         AND e.name    = 'workarea memory allocated'
         AND e.value  >= b.value
         AND e.value  >  0;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4">PGA Memory Statistics</TH></TR>'||
                ' <TR><TD COLSPAN="4" ALIGN="center">WorkArea (W/A) memory is used for: sort, bitmap merge, and hash join ops</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Begin</TH>'||
                '<TH CLASS="th_sub">End</TH><TH CLASS="th_sub">Diff</TH></TR>';
      print(L_LINE);
      FOR R_PGAM IN C_PGAM LOOP
        IF R_PGAM.st = 'cache hit percentage' THEN
          SN1 := TO_CHAR(R_PGAM.snap1,'990.0')||' %';
          SN2 := TO_CHAR(R_PGAM.snap2,'990.0')||' %';
        ELSE
          SN1 := format_fsize(R_PGAM.snap1);
          SN2 := format_fsize(R_PGAM.snap2);
        END IF;
        L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAM.st||'</TD><TD ALIGN="right">'||
                  SN1||'</TD><TD ALIGN="right">'||SN2||
                  '</TD><TD ALIGN="right">'||R_PGAM.diff||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN
        print(TABLE_CLOSE);
    END;
