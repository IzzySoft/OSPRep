
  -- Resource Limits
  IF MK_RLIMS THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="resourcelimits">Resource Limits</A></TH></TR>'||
              ' <TR><TD COLSPAN="5" ALIGN="center">"Current" is the time of the End SnapShot</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TH CLASS="th_sub">Resource</TH><TH CLASS="th_sub">Curr Utilization</TH>'||
	      '<TH CLASS="th_sub">Max Utilization</TH><TH CLASS="th_sub">'||
	      'Init Allocation</TH><TH CLASS="th_sub">Limit</TH></TR>';
    print(L_LINE);
    FOR R_RLim in C_RLim LOOP
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
