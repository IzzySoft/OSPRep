PROCEDURE get_waitobj(db_id IN NUMBER, instnum IN NUMBER, bid IN NUMBER, eid IN NUMBER) IS
 CURSOR cur IS
  SELECT owner,segment_name,segment_type,event,waited,entries FROM (
   SELECT owner,segment_name,segment_type,event,sum(waited) waited,count(waited) entries
     FROM ( SELECT snap_id,owner,segment_name,segment_type,event,
                   DECODE(wait_time,0,seconds_in_wait,wait_time) waited,
 		   instance_number,dbid
 	      FROM istats$waitobjects )
    WHERE dbid = db_id
      AND instance_number = instnum
      AND snap_id BETWEEN bid AND eid
    GROUP BY owner,segment_name,segment_type,event
    ORDER BY waited DESC,entries DESC )
   WHERE rownum <= TOP_N_WAITS;
 BEGIN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="waitobjects">Top '||
              TOP_N_WAITS||' Objects waited for</TH></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="5"><DIV ALIGN="center">Ordered by Waited desc, Entries desc</DIV>'||
              '<DIV ALIGN="justify">Since Oracle stores the waited time only as ';
    print(L_LINE);
    L_LINE := 'integer values (full seconds), the summed up waited time is not that '||
              'correct - since even 100 times 0.4 secs would show up as 0. The '||
	      'column Entries sums up ';
    print(L_LINE);
    L_LINE := 'how often the object was found in the wait events list for this '||
              'event.</TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Type</TH>'||
              '<TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waited (s)</TH>'||
	      '<TH CLASS="th_sub">Entries</TH></TR>';
    print(L_LINE);
    FOR rec IN cur LOOP
      L_LINE := ' <TR><TD>'||rec.owner||'.'||rec.segment_name||'</TD><TD>'||
                rec.segment_type||'</TD><TD>'||rec.event||'</TD><TD ALIGN="right">'||
		rec.waited||'</TD><TD ALIGN="right">'||rec.entries||'</TD></TR>';
      print(L_LINE);
    END LOOP;
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    print('<HR>');
 EXCEPTION
   WHEN OTHERS THEN NULL;
 END;
