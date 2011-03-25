
  PROCEDURE init_ora IS
    CURSOR C_IParm IS
      SELECT e.name,
             nvl(b.value,'&nbsp;') bval,
             decode(b.value,e.value,'&nbsp;',e.value) eval
        FROM stats$parameter b, stats$parameter e
       WHERE b.snap_id(+) = bid
         AND e.snap_id    = eid
         AND b.dbid(+)    = DB_ID
         AND e.dbid       = DB_ID
         AND b.instance_number(+) = INST_NUM
         AND e.instance_number    = INST_NUM
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
      FOR R_IParm in C_IParm LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||R_IParm.name||'</TD><TD>'||
                  R_IParm.bval||'</TD><TD>'||R_IParm.eval||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;
