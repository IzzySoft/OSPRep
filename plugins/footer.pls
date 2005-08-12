
  -- Page Ending
  print(TABLE_OPEN);
  L_LINE := '<TR><TD><IMG SRC="w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small">';
  print(L_LINE);
  L_LINE := 'Created by OSPRep v'||OSPVER||' &copy; 2003-2005 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></SPAN>';
  print(L_LINE);
  L_LINE := '<IMG SRC="islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14"'||
            ' ALIGN="middle" STYLE="margin-left:3px"></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

EXCEPTION
  WHEN invalid_snap_range THEN
    print(CHR(10)||'The value of the last snapshot specified is equal or less the value of the');
    print('first snapshot specified. The reason can be:');
    print('- you specified a wrong range on the command line (parameters -b and -e)');
    print('- you specified a wrong range in the config file');
    L_LINE := '- StatsPack skipped some Snap_IDs, and we tried to find the closest matching;'||CHR(10)||
              '  but due to the "whole" the values crossed';
    print(L_LINE);
    print(CHR(10)||'Your range specification: '||START_ID||' - '||END_ID);
    print('Adjusted by OSPRep to: '||BID||' - '||EID);
    print(CHR(10)||'If the values specified by you differ from the adjusted ones, it is most likely');
    print('that there is a gap in Statspacks snap_ids. To find out about this, check the');
    print('stats$snapshot table with e.g.'||CHR(10)||
          '  SELECT snap_id FROM stats$snapshot WHERE snap_id between '||EID||' AND '||BID||CHR(10));
END;
/

SPOOL off
