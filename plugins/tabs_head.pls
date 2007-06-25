  PROCEDURE tabs IS
    pcomment VARCHAR2(2000);

    Procedure writestat (statname IN VARCHAR2, comment IN VARCHAR2) IS
      BEGIN
        IF comment IS NULL THEN S2 := '&nbsp;';
          ELSE S2 := comment;
        END IF;
        S1 := numformat( dbstat(statname) );
        print(' <TR><TD>'||statname||'</TD><TD ALIGN="right">'||S1||'</TD><TD>'||S2||'</TD></TR>');
      EXCEPTION
        WHEN OTHERS THEN
	  BEGIN
	    print(' <TR><TD>'||statname||'</TD><TD ALIGN="right">'||S1||'</TD><TD>&nbsp;</TD></TR>');
	  EXCEPTION
	    WHEN OTHERS THEN NULL;
	  END;
      END;

    PROCEDURE tabscan IS
      BEGIN
        L_LINE := ' <TR><TD COLSPAN="3" CLASS="td_name" STYLE="text-align:center">If we have many '||
                  'full table scans, we may have to optimize <CODE>DB_FILE_MULTI_BLOCK_READ_COUNT'||
                  '</CODE>:</TD></TR>';
        print(L_LINE);
        writestat('table scans (short tables)','FTS on short tables are no problem, since they are in most times faster than index access.');
        writestat('table scans (long tables)','High values here may indicate missing indices or bad execution plans.');
        writestat('table scans (rowid ranges)','Table scans with specified ROWID endpoints. Used with the Parallel Query Option: The number of RowID ranges corresponds to the number of simultaneous query server processes that scan the table.');
        writestat('table scans (cache partitions)','Count of range scans on tables that have the CACHE option enabled.');
        writestat('table scans (direct read)','Count of table scans performed with direct read (bypassing the buffer cache).');
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    PROCEDURE write(first IN VARCHAR2, last IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := decformat(dbstats(first,last));
        L_LINE := ' <TR><TD STYLE="width:22em">'||first||' / '||last||'</TD><TD ALIGN="right">'||
                  erg||'</TD><TD ALIGN="justify">'||scomment||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="tabs"></A>Table Statistics&nbsp;<A '||
                'HREF="JavaScript:popup('||CHR(39)||'tablestats'||CHR(39)||')"><IMG SRC="help/help.gif" '||
                'BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Value</TH>'||
                '<TH CLASS="th_sub">Comment</TH></TR>';
      print(L_LINE);
      pcomment := 'This ratio (blocks scanned per scanned row) should get close to 0 with '||
                  'acceptable table scan blocks gotten if you are not using LONG objects '||
                  'frequently.';
      write('table scan blocks gotten','table scan rows gotten',pcomment);
      pcomment := 'The chained-fetch-ratio indicates the average chained/migrated rows in '||
                  'multiple blocks, which are accessed by a single ROWID. This ratio should be '||
                  'as low as possible to access a row in a single block.';
      write('table fetch continued row','table fetch by rowid',pcomment);
      IF MK_TABSCAN THEN
        tabscan;
      END IF;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

