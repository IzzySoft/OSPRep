
  PROCEDURE init_ora IS
    CURSOR C_IParm (db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
      SELECT e.name,
             nvl(b.value,'&nbsp;') bval,
             decode(b.value,e.value,'&nbsp;',e.value) eval
        FROM stats$parameter b, stats$parameter e
       WHERE b.snap_id(+) = bid
         AND e.snap_id    = eid
         AND b.dbid(+)    = db_id
         AND e.dbid       = db_id
         AND b.instance_number(+) = instnum
         AND e.instance_number    = instnum
         AND b.name(+)    = e.name
         AND (   nvl(b.isdefault,'X')   = 'FALSE'
              or nvl(b.ismodified,'X') != 'FALSE'
              or     e.ismodified      != 'FALSE'
	      or nvl(e.value,0)        != nvl(b.value,0) );

    BEGIN
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
