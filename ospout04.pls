
  -- Dictionary Cache
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="caches">Dictionary Cache</A></TH></TR>'||
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
  FOR R_CA IN C_CAD(DBID,INST_NUM,BID,EID) LOOP
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

  -- Library Cache
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
  FOR R_CA IN C_CAM(DBID,INST_NUM,BID,EID) LOOP
    S1 := alert_gt_warn(R_CA.ngetm,40,15);
    S2 := alert_gt_warn(R_CA.rpg,30,10);
    S3 := alert_gt_warn(R_CA.ipg,20,10);
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
  print('<HR>');

  -- SGA Memory Summary
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="sga">SGA Memory Summary</A></TH></TR>'||
            ' <TR><TD COLSPAN="2" ALIGN="center">Values at the time of the End SnapShot</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">SGA Region</TH><TH CLASS="th_sub">Size in Bytes</TH>';
  print(L_LINE);
  I1 := 0;
  FOR R_SGASum in C_SGASum(DBID,INST_NUM,BID,EID) LOOP
    I1 := I1 + R_SGASum.rawval;
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.name||'</TD><TD ALIGN="right">'||
              R_SGASum.val||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD>Sum</TD><TD ALIGN="right">'||to_char(I1,'999,999,999,990')||
            '</TD></TR>'||TABLE_CLOSE;
  print(L_LINE);

  -- SGA breakdown diff
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5">SGA BreakDown Difference</TH></TR>'||
            ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Name</TH>'||
	    '<TH CLASS="th_sub">Begin Value</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">End Value</TH><TH CLASS="th_sub">% Diff</TH></TR>';
  print(L_LINE);
  FOR R_SGASum in C_SGABreak(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_SGASum.pool||'</TD><TD CLASS="td_name">'||
              R_SGASum.name||'</TD><TD ALIGN="right">'||R_SGASum.snap1||
	      '</TD><TD ALIGN="right">'||R_SGASum.snap2||'</TD><TD ALIGN="right">'||
	      R_SGASum.diff||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Resource Limits
  IF MK_RLIMS THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="resourcelimits">Resource Limits</A></TH></TR>'||
              ' <TR><TD COLSPAN="5" ALIGN="center">"Current" is the time of the End SnapShot</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TH CLASS="th_sub">Resource</TH><TH CLASS="th_sub">Curr Utilization</TH>'||
	      '<TH CLASS="th_sub">Max Utilization</TH><TH CLASS="th_sub">'||
	      'Init Allocation</TH><TH CLASS="th_sub">Limit</TH></TR>';
    print(L_LINE);
    FOR R_RLim in C_RLim(DBID,INST_NUM,BID,EID) LOOP
      L_LINE := ' <TR><TD CLASS="td_name">'||R_RLim.rname||'</TD><TD ALIGN="right">'||
                R_RLim.curu||'</TD><TD ALIGN="right">'||R_RLim.maxu||
	        '</TD><TD ALIGN="right">'||R_RLim.inita||'</TD><TD ALIGN="right">'||
	        R_RLim.lim||'</TD></TR>';
      print(L_LINE);
    END LOOP;
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    print('<HR>');
  END IF;

  -- Init.Ora Params
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="initora">Initialization Parameters (init.ora)</A></TH></TR>'||
            ' <TR><TH CLASS="th_sub">Parameter Name</TH><TH CLASS="th_sub">Begin Value</TH>'||
	    '<TH CLASS="th_sub">End Value (if different)</TH></TR>';
  print(L_LINE);
  FOR R_IParm in C_IParm(DBID,INST_NUM,BID,EID) LOOP
    L_LINE := ' <TR><TD CLASS="td_name">'||R_IParm.name||'</TD><TD>'||
              R_IParm.bval||'</TD><TD>'||R_IParm.eval||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);


  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  print(L_LINE);
  L_LINE := '<TR><TD><DIV CLASS="small">Created by OSPRep v'||OSPVER||' &copy; 2003-2004 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></DIV></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off
