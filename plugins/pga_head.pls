
  PROCEDURE pgaa IS
    CURSOR C_PGAA (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT 'B' snap,
             to_char(to_number(p.value)/1024/1024,'999,990.00')  pgaat,
             to_char(mu.PGA_inuse/1024/1024,'999,990.00')        tot_pga_used,
	     to_char( (mu.PGA_used_auto + mu.PGA_used_man)
	            /1024/1024,'999,990.00')                   tot_tun_used,
             to_char(mu.onepr/1024/1024,'999,990.00')            onepr,
	     nvl(to_char(s.opt_pct,'990.00'),'&nbsp;')           opt_pct,
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
	        WHERE pga.snap_id = bid
	          AND pga.dbid    = db_id
	          AND pga.instance_number = instnum ) mu,
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
		           AND snap_id = bid) b )              s,
	     stats$parameter p
       WHERE p.snap_id = bid
         AND p.dbid    = db_id
         AND p.instance_number = instnum
         AND p.name    = 'pga_aggregate_target'
         AND p.value  != 0
      UNION SELECT 'E' snap,
             to_char(to_number(p.value)/1024/1024,'999,990.00')  pgaat,
             to_char(mu.PGA_inuse/1024/1024,'999,990.00')        tot_pga_used,
	     to_char( (mu.PGA_used_auto + mu.PGA_used_man)
	            /1024/1024,'999,990.00')                   tot_tun_used,
             to_char(mu.onepr/1024/1024,'999,990.00')            onepr,
	     nvl(to_char(s.opt_pct,'990.00'),'&nbsp;')           opt_pct,
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
	        WHERE pga.snap_id = eid
	          AND pga.dbid    = db_id
	          AND pga.instance_number = instnum ) mu,
             ( SELECT DECODE(NVL(a.sval,0),0,NULL,100*b.oval/a.sval) opt_pct
                 FROM ( SELECT SUM(NVL(value,0)) sval 
	                  FROM stats$sysstat
	                 WHERE name IN ('workarea executions - optimal',
		                        'workarea executions - onepass',
		                        'workarea executions - multipass')
                           AND snap_id = eid) a,
                      ( SELECT SUM(NVL(value,0)) oval
	                  FROM stats$sysstat
                         WHERE name = 'workarea executions - optimal'
		           AND snap_id = eid) b )              s,
             stats$parameter p
       WHERE p.snap_id = eid
         AND p.dbid    = db_id
         AND p.instance_number = instnum
         AND p.name    = 'pga_aggregate_target'
         AND p.value  != 0;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="pga">PGA Aggreg Target Memory Statistics</A></TH></TR>'||
                ' <TR><TD COLSPAN="9" ALIGN="center">B: Begin SnapShot, E: End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">PGA Aggreg Target (M)</TH>'||
                '<TH CLASS="th_sub">PGA in Use (M)</TH><TH CLASS="th_sub">W/A PGA in Use (M)</TH>'||
	        '<TH CLASS="th_sub">1-Pass Mem Req (M)</TH>';
      print(L_LINE);
      L_LINE:= '<TH CLASS="th_sub">% Optim W/A Execs</TH><TH CLASS="th_sub">% Non-W/A PGA Memory</TH>'||
               '<TH CLASS="th_sub">% Auto W/A PGA Mem</TH>'||
	       '<TH CLASS="th_sub">% Manual W/A PGA Mem</TH></TR>';
      print(L_LINE);
      FOR R_PGAA IN C_PGAA(DBID,INST_NUM,BID,EID) LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAA.snap||'</TD><TD ALIGN="right">'||
                  R_PGAA.pgaat||'</TD><TD ALIGN="right">'||R_PGAA.tot_pga_used||
	          '</TD><TD ALIGN="right">'||R_PGAA.tot_tun_used;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right">'||R_PGAA.onepr||'</TD><TD ALIGN="right">'||
                  R_PGAA.opt_pct||'</TD><TD ALIGN="right">'||R_PGAA.pct_unt||
	          '</TD><TD ALIGN="right">'||R_PGAA.pct_auto_tun||
                  '</TD><TD ALIGN="right">'||R_PGAA.pct_man_tun||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE pgam IS
    CURSOR C_PGAM (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT b.name st,
             to_char(b.value/1024/1024,'9,999,990.00') snap1,
             to_char(e.value/1024/1024,'9,999,990.00') snap2,
	     nvl(to_char(decode(b.value,0,NULL,
	                    100*((e.value - nvl(b.value,0))/b.value)),
	                '9,999,999,990.00'),'&nbsp') diff
        FROM stats$pgastat b, stats$pgastat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.name    = e.name
         AND e.value  >= b.value
         AND e.value  >  0
      UNION SELECT b.name st,
             to_char(b.value/1024/1024,'9,999,990.00') snap1,
             to_char(e.value/1024/1024,'9,999,990.00') snap2,
             to_char(decode(b.value,0,100* (e.value - nvl(b.value,0)),
	                            100*((e.value - nvl(b.value,0))/b.value)),
		   '990.00') diff
        FROM stats$sysstat b, stats$sysstat e
       WHERE b.snap_id = bid
         AND e.snap_id = eid
         AND b.dbid    = db_id
         AND e.dbid    = db_id
         AND b.instance_number = instnum
         AND e.instance_number = instnum
         AND b.name    = e.name
         AND e.name    = 'workarea memory allocated'
         AND e.value  >= b.value
         AND e.value  >  0;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4">PGA Memory Statistics</TH></TR>'||
                ' <TR><TD COLSPAN="4" ALIGN="center">WorkArea (W/A) memory is used for: sort, bitmap merge, and hash join ops</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Begin (M)</TH>'||
                '<TH CLASS="th_sub">End (M)</TH><TH CLASS="th_sub">% Diff</TH></TR>';
      print(L_LINE);
      FOR R_PGAM IN C_PGAM(DBID,INST_NUM,BID,EID) LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_PGAM.st||'</TD><TD ALIGN="right">'||
                  R_PGAM.snap1||'</TD><TD ALIGN="right">'||R_PGAM.snap2||
	          '</TD><TD ALIGN="right">'||R_PGAM.diff||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
