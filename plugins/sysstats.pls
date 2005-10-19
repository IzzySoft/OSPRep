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
