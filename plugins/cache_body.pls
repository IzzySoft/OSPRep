  print('<A NAME="caches"></A>');
  -- Cache Sizes
  IF MK_CACHSIZ = 1 THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="cachesizes">Cache Sizes (End)</A></TH></TR>'||CHR(10)||
              ' <TR><TH CLASS="th_sub">Cache</TH><TH CLASS="th_sub">Size</TH></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD>Buffer Cache</TD><TD ALIGN="right">'||to_char(round(BC/1024/1024),'999,999')||' M</TD></TR>'||
              ' <TR><TD>Std Block Size</TD><TD ALIGN="right">'||to_char(round(BS/1024),'999,999')||' K</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD>Shared Pool Size</TD><TD ALIGN="right">'||to_char(round(SP/1024/1024),'999,999')||' M</TD></TR>'||
              ' <TR><TD>Log Buffer</TD><TD ALIGN="right">'||to_char(round(LB/1024),'999,999')||' K</TD></TR>';
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
