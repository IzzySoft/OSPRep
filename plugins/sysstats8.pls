  FUNCTION dbstat(first IN VARCHAR2) RETURN NUMBER IS
    erg NUMBER;
    BEGIN
      SELECT a.val INTO erg
        FROM (
         SELECT decode(e.name,first,e.value) - decode (b.name,first,b.value) val
          FROM stats$sysstat b, stats$sysstat e
         WHERE b.snap_id = BID
           AND e.snap_id = EID
           AND b.dbid    = DB_ID
           AND e.dbid    = DB_ID
           AND b.dbid    = e.dbid
           AND b.instance_number = INST_NUM
           AND e.instance_number = INST_NUM
           AND b.instance_number = e.instance_number
           AND decode(e.name,first,e.value) IS NOT NULL
           AND decode(b.name, first,b.value) IS NOT NULL ) a;
      RETURN erg;
    EXCEPTION
      WHEN OTHERS THEN RETURN 0;
    END;

  FUNCTION dbstats(first IN VARCHAR2, last IN VARCHAR2) RETURN NUMBER IS
    erg NUMBER;
    BEGIN
      SELECT ( a.val / b.val ) INTO erg
        FROM (
         SELECT decode(e.name,first,e.value) - decode (b.name,first,b.value) val
          FROM stats$sysstat b, stats$sysstat e
         WHERE b.snap_id = BID
           AND e.snap_id = EID
           AND b.dbid    = DB_ID
           AND e.dbid    = DB_ID
           AND b.dbid    = e.dbid
           AND b.instance_number = INST_NUM
           AND e.instance_number = INST_NUM
           AND b.instance_number = e.instance_number
           AND decode(e.name,first,e.value) IS NOT NULL
           AND decode(b.name, first,b.value) IS NOT NULL ) a, (
         SELECT decode(e.name,last,e.value) - decode (b.name,last,b.value) val
          FROM stats$sysstat b, stats$sysstat e
         WHERE b.snap_id = BID
           AND e.snap_id = EID
           AND b.dbid    = DB_ID
           AND e.dbid    = DB_ID
           AND b.dbid    = e.dbid
           AND b.instance_number = INST_NUM
           AND e.instance_number = INST_NUM
           AND b.instance_number = e.instance_number
           AND decode(e.name,last,e.value) IS NOT NULL
           AND decode(b.name, last,b.value) IS NOT NULL ) b
        WHERE b.val > 0;
      RETURN erg;
    EXCEPTION
      WHEN OTHERS THEN RETURN 0;
    END;

  FUNCTION parameter(name IN VARCHAR2) RETURN VARCHAR2 IS
    wert VARCHAR2(200);
    statement VARCHAR2(500);
    BEGIN
      statement := 'SELECT value FROM stats$parameter WHERE name='''||name||''''||
                   ' AND snap_id='||EID||' AND dbid='||DB_ID||
                   ' AND instance_number='||INST_NUM;
      EXECUTE IMMEDIATE statement INTO wert;
      RETURN wert;
    EXCEPTION
      WHEN OTHERS THEN wert := ''; RETURN wert;
    END;

  PROCEDURE eventstat(eventname IN VARCHAR2, average OUT NUMBER, totals OUT NUMBER,
                     waittime OUT NUMBER, timeouts OUT NUMBER) IS
    BEGIN
      SELECT a.totwaits,a.twait/1000,
             DECODE(NVL(a.twait,0),0,0,a.twait/a.totwaits),
             a.time_outs
       INTO totals,waittime,average,timeouts
       FROM (
        SELECT e.total_waits - b.total_waits totwaits,
               e.time_waited - b.time_waited twait,
	       e.total_timeouts - b.total_timeouts time_outs
          FROM stats$system_event b, stats$system_event e
         WHERE b.snap_id = BID
           AND e.snap_id = EID
           AND b.dbid    = DB_ID
           AND e.dbid    = DB_ID
           AND b.dbid    = e.dbid
           AND b.instance_number = INST_NUM
           AND e.instance_number = INST_NUM
           AND b.instance_number = e.instance_number
           AND b.event=eventname
           AND e.event=eventname
           AND b.event=e.event) a;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       average := 0; totals := 0; waittime := 0; timeouts := 0;
    END;

  PROCEDURE get_wait(eventname IN VARCHAR2, avgwait OUT VARCHAR2, total_waits OUT VARCHAR2,
                     time_waited OUT VARCHAR2, total_timeouts OUT VARCHAR2) IS
    average NUMBER; totals NUMBER; waittime NUMBER; timeouts NUMBER;
    BEGIN
      eventstat(eventname,average,totals,waittime,timeouts);
      total_waits    := numformat(totals);
      time_waited    := format_stime(waittime,1);
      total_timeouts := numformat(timeouts);
      avgwait        := format_stime(average,1000);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

