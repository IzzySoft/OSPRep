
  -- Page Ending
  print(TABLE_OPEN);
  L_LINE := '<TR><TD><IMG SRC="w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small">';
  print(L_LINE);
  L_LINE := 'Created by OSPRep v'||OSPVER||' &copy; 2003-2004 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></SPAN>';
  print(L_LINE);
  L_LINE := '<IMG SRC="islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-left:3px"></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off
