#!/bin/bash
# =============================================================================
# Oracle StatsPack Report 2 HTML       (c) 2003 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# $Id$
# -----------------------------------------------------------------------------
# Wait Object Stats. This procedure is only included if the according objects
# exist in the perfstat users schema
# =============================================================================

EXCLUDING=`echo $EXCLUDE_OWNERS|sed "s/'//g"`
EXCLUDING=`echo $EXCLUDING|sed "s/,/, /g"`

cat>>$SQLSET<<ENDSQL
PROCEDURE get_waitobj IS
 CURSOR cur IS
  SELECT owner,segment_name,segment_type,event,waited,entries FROM (
   SELECT owner,segment_name,segment_type,event,sum(waited) waited,count(waited) entries
     FROM ( SELECT snap_id,owner,segment_name,segment_type,event,
                   DECODE(wait_time,0,seconds_in_wait,wait_time) waited,
 		   instance_number,dbid
 	      FROM istats\$waitobjects
	     WHERE owner NOT IN ($EXCLUDE_OWNERS) )
    WHERE dbid = DB_ID
      AND instance_number = INST_NUM
      AND snap_id BETWEEN BID AND EID
    GROUP BY owner,segment_name,segment_type,event
    ORDER BY waited DESC,entries DESC )
   WHERE rownum <= TOP_N_WAITS;
 BEGIN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="waitobjects">Top '||
              TOP_N_WAITS||' Objects waited for</A></TH></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="5"><DIV ALIGN="center">Ordered by Waited desc, Entries desc<BR>'||
              'Excluding objects for: $EXCLUDING</DIV>';
    print(L_LINE);
    L_LINE := '<DIV ALIGN="justify">Since Oracle stores the waited time only as '||
              'integer values (full seconds), the summed up waited time is not that '||
              'correct - since even 100 times 0.4 secs ';
    print(L_LINE);
    L_LINE := 'would show up as 0. The column Entries sums up how often the '||
              'object was found in the wait events list for this event.</DIV></TD></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Type</TH>'||
              '<TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Waited (s)</TH>'||
	      '<TH CLASS="th_sub">Entries</TH></TR>';
    print(L_LINE);
    FOR rec IN cur LOOP
      L_LINE := ' <TR><TD CLASS="td_name">'||rec.owner||'.'||rec.segment_name||'</TD><TD>'||
                rec.segment_type||'</TD><TD>'||rec.event||'</TD><TD ALIGN="right">'||
		format_stime(rec.waited,1)||'</TD><TD ALIGN="right">'||rec.entries||'</TD></TR>';
      print(L_LINE);
    END LOOP;
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    print('<HR>');
 EXCEPTION
   WHEN OTHERS THEN NULL;
 END;

ENDSQL