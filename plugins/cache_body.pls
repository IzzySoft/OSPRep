  print('<A NAME="caches"></A>');
  -- Cache Sizes
  IF MK_CACHSIZ = 1 THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="cachesizes">Cache Sizes (End)</A></TH></TR>'||CHR(10)||
              ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Size</TH></TR>';
    print(L_LINE);
    S1 := format_fsize(BC);
    S2 := format_fsize(BS);
    S3 := format_fsize(SP);
    S4 := format_fsize(LB);
    L_LINE := ' <TR><TD>Buffer Cache</TD><TD ALIGN="right">'||S1||'</TD></TR>'||
              ' <TR><TD>Std Block Size</TD><TD ALIGN="right">'||S2||'</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD>Shared Pool Size</TD><TD ALIGN="right">'||S3||'</TD></TR>'||
              ' <TR><TD>Log Buffer</TD><TD ALIGN="right">'||S4||'</TD></TR>';
    print(L_LINE);
    print(TABLE_CLOSE);
  END IF;

  -- Cache Stats
  IF MK_DC = 1 THEN
    dictcache;
  END IF;
  IF MK_LC = 1 THEN
    libcache;
  END IF;
  IF MK_DC + MK_LC > 0 THEN
    print('<HR>');
  END IF;
