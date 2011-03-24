-- ===========================================================================
-- Oracle StatsPack Report 2 Html (c)2003-2007 by IzzySoft (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Chart generation package
-- This code gathers the data for the charts. Run this SQL script while
-- connected to Oracle as PERFSTAT (or whatever user you installed the
-- Oracle StatsPack into). If compilation fails with something like "table or
-- view does not exist", "GRANT SELECT ANY DICTIONARY" to your PERFSTAT user.
-- ---------------------------------------------------------------------------
-- $Id$
SET SCAN OFF DEFINE OFF

CREATE OR REPLACE PACKAGE osprep AS
  PROCEDURE chart_data(start_id IN NUMBER := 0, end_id IN NUMBER := 0, max_chart_interval IN NUMBER := 14); -- Create the chart data
  PROCEDURE fts_plan(start_id IN NUMBER := 0, end_id IN NUMBER := 0, max_plan_interval IN NUMBER := 0); -- Create the FTS Execution Plan Report
  PROCEDURE set_exclude_owners(ex_own IN VARCHAR2); -- declare object owners to exclude for FTS
END osprep;
/

CREATE OR REPLACE PACKAGE BODY osprep AS
  L_LINE VARCHAR2(4000);
  DB_ID NUMBER; DB_NAME VARCHAR(9); INST_NUM NUMBER; INST_NAME VARCHAR(16);
  EID NUMBER; BID NUMBER;
  BTIME VARCHAR2(20); ETIME VARCHAR2(20); DBUP_ID NUMBER; TDATE DATE;
  DB_BLOCKSIZE NUMBER; I1 NUMBER;
  exclude_owners VARCHAR2(4000);
  TABLE_OPEN VARCHAR2(100)  := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE VARCHAR2(100) := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);
  -- Go4Colors
  AR_EP_FTS NUMBER := 1000;

/* --------------------------------------------------------------------------
   -----------------------------------------------[ cursors for fts_plan ]---
   -------------------------------------------------------------------------- */
  CURSOR C_GetSQL (hv IN NUMBER) IS
    SELECT replace(replace(sql_text,'<','&lt;'),'>','&gt;') AS sql_text
      FROM stats$sqltext WHERE hash_value=hv
     ORDER BY piece;

  CURSOR C_GetHashes IS
    SELECT DISTINCT a.plan_hash_value AS phashval,
           b.hash_value AS hashval, b.cost,
           TO_CHAR(c.snap_time,'dd.mm.yyyy') AS snapdate
      FROM stats$sql_plan a, stats$sql_plan_usage b, stats$snapshot c
     WHERE a.operation='TABLE ACCESS'
       AND a.options='FULL'
       AND a.snap_id BETWEEN BID AND EID
       AND b.snap_id BETWEEN BID AND EID
       AND c.snap_id BETWEEN BID AND EID
       AND a.plan_hash_value=b.plan_hash_value
       AND b.snap_id=c.snap_id
       AND exclude_owners NOT LIKE '%'''||a.object_owner||'''%'
     ORDER BY b.cost DESC;

/* --------------------------------------------------------------------------
   ---------------------------------------------------[ common functions ]---
   -------------------------------------------------------------------------- */
  -- Initialization - everything that's needed everywhere
  PROCEDURE init IS
    BEGIN
      dbms_output.enable(1000000);
      SELECT d.dbid,d.name,i.instance_number,i.instance_name
        INTO DB_ID,DB_NAME,INST_NUM,INST_NAME
        FROM v$database d,v$instance i;
    END;

  -- Find the "last SnapShot to Report" and store it into EID
  PROCEDURE eval_EID(end_id IN NUMBER := 0) IS
    BEGIN
      SELECT MAX(snap_id) INTO I1 FROM stats$snapshot
       WHERE dbid = DB_ID AND instance_number = INST_NUM;
      IF NVL(end_id,0) = 0 THEN
        EID := I1;
      ELSE
        IF end_id > I1 THEN
          EID := I1;
        ELSE
          EID := end_id;
        END IF;
      END IF;
    END;

  -- Find the ID of the first SnapShot after DBStart and store it into DBUP_ID
  PROCEDURE eval_DBUP_ID IS
    BEGIN
      SELECT MIN(snap_id) INTO DBUP_ID FROM stats$snapshot
       WHERE dbid = DB_ID AND instance_number = INST_NUM
         AND startup_time = (SELECT startup_time FROM stats$snapshot
                            WHERE dbid = db_id AND instance_number = INST_NUM
		 AND snap_id = EID);
    END;

  -- Find the "first SnapShot to Report" and store it into BID
  PROCEDURE eval_BID(start_id IN NUMBER := 0, max_interval NUMBER := 0) IS
    BEGIN
      IF NVL(start_id,0) = 0 THEN
        IF NVL(max_interval,0) != 0 THEN
          SELECT (snap_time - max_interval) INTO TDATE FROM stats$snapshot WHERE snap_id=EID;
          SELECT MAX(snap_id) INTO BID FROM stats$snapshot WHERE snap_time<TDATE;
          IF BID < DBUP_ID OR BID IS NULL THEN BID := DBUP_ID; END IF;
        ELSE
          BID := DBUP_ID;
        END IF;
      ELSE
        IF start_id < DBUP_ID THEN BID := DBUP_ID;
        ELSE BID := start_id;
        END IF;
      END IF;
    END;

  -- Set up BTIME, ETIME and DB_BLOCKSIZE
  PROCEDURE eval_common IS
    BEGIN
      SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO BTIME
        FROM stats$snapshot
       WHERE snap_id=BID;
      SELECT TO_CHAR(snap_time,'dd.mm.yyyy hh24:mi') INTO ETIME
        FROM stats$snapshot
       WHERE snap_id=EID;
      SELECT value INTO DB_BLOCKSIZE
        FROM stats$parameter
       WHERE name='db_block_size'
         AND snap_id = EID
         AND instance_number=INST_NUM
         AND dbid=DBID;
    END;

  -- The dbms_output.put_line wrapper
  FUNCTION strpos (str IN VARCHAR2,needle IN VARCHAR2,startpos NUMBER) RETURN NUMBER IS
    pos NUMBER; strsub VARCHAR2(255);
    BEGIN
      strsub := SUBSTR(str,1,255);
      pos    := INSTR(strsub,needle,startpos);
      return pos;
    END;

  PROCEDURE print(line IN VARCHAR2) IS
    pos NUMBER;
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLERRM LIKE '%ORU-10028%' THEN
          pos := strpos(line,' ',-1);
	  print(SUBSTR(line,1,pos));
	  pos := pos +1;
	  print(SUBSTR(line,pos));
	ELSE
          dbms_output.put_line('*!* Problem in print() *!*');
	END IF;
    END;

/* --------------------------------------------------------------------------
   ----------------------------------------------------[ chart functions ]---
   -------------------------------------------------------------------------- */
  PROCEDURE get_sysevent(eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sev IS
      SELECT arrname||'['||snap_id||'] = '||total_timeouts||';' line,
             NVL(total_timeouts,0) value, snap_id
        FROM stats$system_event
       WHERE event=eventname
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sev LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sysstat(eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||snap_id||'] = '||value||';' line, value, snap_id
        FROM stats$sysstat
       WHERE name=eventname
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sesstat(eventname IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||a.snap_id||'] = '||a.value||';' line, a.value, a.snap_id
        FROM stats$sesstat a, v$statname b
       WHERE b.name=eventname
         AND a.statistic#=b.statistic#
         AND a.instance_number=INST_NUM
	 AND a.dbid=DB_ID
	 AND a.snap_id BETWEEN BID AND EID;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        get_sysstat(eventname,arrname);
    END;

  PROCEDURE get_sysstat2_ps(event1 IN VARCHAR2, event2 IN VARCHAR2, arrname IN VARCHAR2) IS
    MAXVAL NUMBER; LASTVAL NUMBER; ACTVAL NUMBER; VALUE NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||snap_id||'] = '||SUM(value)||';' line,snap_id,SUM(value) val
        FROM stats$sysstat
       WHERE name IN (event1,event2)
         AND instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        ACTVAL := rec.val;
        IF rec.snap_id > bid THEN
          VALUE := ACTVAL - LASTVAL;
          print(arrname||'['||rec.snap_id||'] = '||VALUE||';');
	  IF VALUE > MAXVAL THEN
	    MAXVAL := VALUE;
          END IF;
        END IF;
	LASTVAL := ACTVAL;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_sysstat_per(event1 IN VARCHAR2, event2 IN VARCHAR2, arrname IN VARCHAR2, factor IN NUMBER) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Sys IS
      SELECT arrname||'['||a.snap_id||'] = '||round(factor*a.value/b.value,5)||';' line,
             a.snap_id, round(factor*a.value/b.value,5) value
        FROM stats$sysstat a, stats$sysstat b
       WHERE a.name=event1
         AND b.name=event2
         AND a.instance_number=INST_NUM
         AND b.instance_number=INST_NUM
	 AND a.dbid=DB_ID
	 AND b.dbid=DB_ID
	 AND a.snap_id BETWEEN BID AND EID
	 AND a.snap_id=b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Sys LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_libmiss(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Lib IS
      SELECT arrname||'['||snap_id||'] = '||
             decode(nvl(sum(gets),0),0,0,100-nvl((sum(gethits)/sum(gets)),0)*100)||
	     ';' line, snap_id,
             decode(nvl(sum(gets),0),0,0,100-nvl((sum(gethits)/sum(gets)),0)*100) value
        FROM stats$librarycache
       WHERE snap_id BETWEEN BID AND EID
         AND dbid = DB_ID
         AND instance_number = INST_NUM
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Lib LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	IF ( rec.snap_id - DBUP_ID ) > 0 THEN
          IF rec.value / (rec.snap_id - DBUP_ID) > MAXAVEDELTA THEN
            MAXAVEDELTA := rec.value / (rec.snap_id - DBUP_ID);
          END IF;
	END IF;
	IF ABS(rec.value - LASTVAL) > MAXDELTA THEN
	  MAXDELTA := ABS(rec.value - LASTVAL);
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
      print('amaxavedelta["'||arrname||'"] = '||MAXAVEDELTA||';');
      print('amaxdelta["'||arrname||'"] = '||MAXDELTA||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_librpp(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_LibR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(reloads)/sum(pins),3)||';' line,
             snap_id, round(100*sum(reloads)/sum(pins),3) value
        FROM stats$librarycache
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_LibR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_libghr(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_LibR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(gethits)/sum(gets),3)||';' line,
             snap_id, round(100*sum(gethits)/sum(gets),3) value
        FROM stats$librarycache
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_LibR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_rowcacheratio(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_RowR IS
      SELECT arrname||'['||snap_id||'] = '||round(100*sum(getmisses)/sum(gets),3)||';' line,
             snap_id, round(100*sum(getmisses)/sum(gets),3) value
        FROM stats$rowcache_summary
       WHERE instance_number=INST_NUM
	 AND dbid=DB_ID
	 AND snap_id BETWEEN BID AND EID
       GROUP BY snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_RowR LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_filereads(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Read IS
      SELECT arrname||'['||b.snap_id||'] = '||round(sum(e.phyblkrd - b.phyblkrd)*DB_BLOCKSIZE/1024/1024,2)||';' line,
             b.snap_id snap_id,
	     round(sum(e.phyblkrd - b.phyblkrd)*DB_BLOCKSIZE/1024/1024,2) value
        FROM stats$filestatxs b, stats$filestatxs e
       WHERE e.dbid = DB_ID
         AND b.dbid = DB_ID
         AND e.instance_number = INST_NUM
         AND b.instance_number = INST_NUM
         AND e.snap_id = b.snap_id +1
         AND b.snap_id BETWEEN BID AND EID -1
         AND b.tsname = e.tsname
         AND b.filename = e.filename
       GROUP BY b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Read LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
	LASTVAL := rec.value;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE get_filewrites(arrname IN VARCHAR2) IS
    MAXVAL NUMBER; MAXDELTA NUMBER; MAXAVEDELTA NUMBER; LASTVAL NUMBER;
    CURSOR C_Read IS
      SELECT arrname||'['||b.snap_id||'] = '||round(sum(e.phyblkwrt - b.phyblkwrt)*DB_BLOCKSIZE/1024/1024,2)||';' line,
             b.snap_id snap_id,
	     round(sum(e.phyblkwrt - b.phyblkwrt)*DB_BLOCKSIZE/1024/1024,2) value
        FROM stats$filestatxs b, stats$filestatxs e
       WHERE e.dbid = DB_ID
         AND b.dbid = DB_ID
         AND e.instance_number = INST_NUM
         AND b.instance_number = INST_NUM
         AND e.snap_id = b.snap_id +1
         AND b.snap_id BETWEEN bid AND eid -1
         AND b.tsname = e.tsname
         AND b.filename = e.filename
       GROUP BY b.snap_id;
    BEGIN
      MAXVAL := 0; MAXDELTA := 0; MAXAVEDELTA :=0; LASTVAL := 0;
      print(CHR(10)||'var '||arrname||' = new Array();');
      FOR rec IN C_Read LOOP
        print(rec.line);
	IF rec.value > MAXVAL THEN
	  MAXVAL := rec.value;
	END IF;
      END LOOP;
      print('amaxval["'||arrname||'"] = '||MAXVAL||';');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

/* --------------------------------------------------------------------------
   --------------------------------------------[ procedures for fts_plan ]---
   -------------------------------------------------------------------------- */
  PROCEDURE get_plan (hashval IN VARCHAR2) IS
    HASHID NUMBER; CI NUMBER; SI NUMBER; OSIZE VARCHAR2(50); IND VARCHAR2(255);
    CW NUMBER; S1 VARCHAR2(50); TDI VARCHAR2(20);
    CURSOR C_PGet (hash_val IN VARCHAR2) IS
      SELECT operation,options,object_owner,object_name,optimizer,
             NVL(TO_CHAR(cost,'999,990'),'&nbsp;') cost,
             cost ncost,
             bytes,cpu_cost,io_cost,depth
        FROM stats$sql_plan,
	     ( SELECT MAX(snap_id) maxid FROM stats$sql_plan
	        WHERE snap_id BETWEEN BID AND EID
		  AND plan_hash_value = hash_val ) id
       WHERE plan_hash_value = hash_val
	 ORDER BY id;
    BEGIN
      SELECT MAX(snap_id) INTO SI
        FROM ( SELECT plan_hash_value,snap_id
                 FROM stats$sql_plan_usage
                WHERE hash_value = hashval
                  AND snap_id BETWEEN BID AND EID );
      SELECT MAX(plan_hash_value) INTO HASHID
        FROM ( SELECT plan_hash_value,snap_id
                 FROM stats$sql_plan_usage
                WHERE hash_value = hashval
                  AND snap_id=SI );
      SELECT COUNT(snap_id) INTO CI
        FROM stats$sql_plan
       WHERE plan_hash_value = HASHID
         AND exclude_owners NOT LIKE '%'''||object_owner||'''%';
      IF CI > 0
      THEN
        CW := 20;
        print('<TR><TD COLSPAN="7">');
        print(TABLE_OPEN||'<TR><TH CLASS="th_sub">Operation</TH><TH CLASS="th_sub">'||
              'Object</TH><TH CLASS="th_sub">');
        print('Optimizer</TH><TH CLASS="th_sub">Cost</TH><TH CLASS="th_sub">'||
              'CPUCost</TH><TH CLASS="th_sub">IOCost</TH><TH CLASS="th_sub">'||
              'Size</TH></TR>');
        FOR rplan IN C_PGet(HASHID) LOOP
          IF NVL(rplan.bytes,0) < 1024 THEN
            OSIZE := TO_CHAR(rplan.bytes,'9,990');
            IF NVL(OSIZE,'X') = 'X' THEN
              OSIZE := '&nbsp;';
            ELSE
              OSIZE := OSIZE||' b';
            END IF;
          ELSE
            OSIZE := TO_CHAR(rplan.bytes/1024,'999,999,990')||' k';
          END IF;
	  IND := '';
	  FOR CI IN 1..rplan.depth LOOP
	    IND := IND||'. ';
	  END LOOP;
	  SI := 11*(LENGTH(rplan.operation) + LENGTH(rplan.options) + 2*rplan.depth)/9;
	  CI := 3*(LENGTH(OSIZE)+1)/10;
	  IF SI > CW THEN CW := SI; END IF;
	  IF rplan.operation||' '||rplan.options = 'TABLE ACCESS FULL' THEN
	    IF NVL(rplan.ncost,0) > AR_EP_FTS THEN
	      S1 := ' CLASS="alert"';
	    ELSE
	      S1 := ' CLASS="warn"';
	    END IF;
            TDI := '';
	  ELSE
	    S1 := '';
            TDI := ' CLASS="inner"';
	  END IF;
          print('<TR'||S1||'><TD'||TDI||'><DIV STYLE="width:'||5*CW/9||'em"><CODE>'||IND||rplan.operation||' '||rplan.options||
                '</CODE></DIV></TD><TD'||TDI||'>'||rplan.object_owner||'.'||rplan.object_name||
                '</TD><TD'||TDI||'>'||NVL(rplan.optimizer,'&nbsp;'));
          print('</TD><TD ALIGN="right"'||TDI||'>'||rplan.cost||'</TD><TD ALIGN="right"'||TDI||'>'||
                NVL(TO_CHAR(rplan.cpu_cost,'999,990'),'&nbsp;')||
                '</TD><TD ALIGN="right"'||TDI||'>'||NVL(TO_CHAR(rplan.io_cost,'999,990'),'&nbsp;')||
                '</TD><TD ALIGN="right"'||TDI||'><DIV STYLE="width:'||CI||'em">'||OSIZE||'</DIV></TD></TR>');
        END LOOP;
        print('</TABLE></TD></TR>');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  PROCEDURE plan_table IS
    bufgets VARCHAR2(25); exe VARCHAR2(255); diskreads VARCHAR2(255);
    numrows VARCHAR2(25); cputime NUMBER; elapsed NUMBER; module VARCHAR2(64);
    max_id NUMBER; min_id NUMBER;
    BEGIN
      -- Make the Plan tables
      print('<H3 ALIGN="center">Full Table Scans between SnapID '||BID||' ('||BTIME||') and '||EID||' ('||ETIME||')</H3>');
      print(TABLE_OPEN||' <TR><TH>LastRec</TH><TH>BufferGets</TH><TH>Executions</TH><TH>DiskReads</TH>'
            ||'<TH>RowsProc''d</TH><TH>CPUTime</TH><TH>Elapsed</TH><TH>Module</TH></TR>');
      FOR recHash in C_GetHashes LOOP
        BEGIN
         SELECT MAX(snap_id) INTO max_id FROM stats$sql_summary
          WHERE hash_value = recHash.hashval AND snap_id<EID+1
            AND instance_number = INST_NUM AND dbid = DB_ID;
         BEGIN
           SELECT MIN(snap_id) INTO min_id FROM stats$sql_summary
            WHERE hash_value = recHash.hashval AND snap_id>BID-1 AND snap_id<max_id
              AND instance_number = INST_NUM AND dbid = DB_ID;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             BEGIN
               SELECT MAX(snap_id) INTO min_id FROM stats$sql_summary
                WHERE hash_value = recHash.hashval AND snap_id<BID
                  AND instance_number = INST_NUM AND dbid = DB_ID;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN min_id := BID;
             END;
         END;        
          SELECT TRIM(to_char((e.buffer_gets - nvl(b.buffer_gets,0)),'99,999,999,990')),
                 TRIM(to_char(e.executions - nvl(b.executions,0),'999,999,990')),
                 TRIM(to_char((e.disk_reads - nvl(b.disk_reads,0)),'99,999,999,990')),
                 TRIM(to_char((e.rows_processed - nvl(b.rows_processed,0)),'99,999,999,990')),
                 (e.cpu_time - nvl(b.cpu_time,0))/1000,
       	         (e.elapsed_time - nvl(b.elapsed_time,0))/1000,
                 e.module
            INTO bufgets,exe,diskreads,numrows,cputime,elapsed,module
            FROM stats$sql_summary e, stats$sql_summary b
           WHERE e.snap_id = max_id AND b.snap_id(+) = min_id
             AND b.hash_value(+) = e.hash_value
             AND b.text_subset(+) = e.text_subset
             AND e.instance_number = INST_NUM
             AND b.instance_number(+) = INST_NUM
             AND e.dbid = DB_ID AND b.dbid(+) = DB_ID
--             AND e.executions  > nvl(b.executions,0) -- was executed in the given snapshot interval
             AND e.hash_value = recHash.hashval;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            bufgets := '?'; exe := '?'; diskreads := '?'; numrows := '?';
            cputime := 0; elapsed := 0; module := '&nbsp;';
        END;
        print('<TR><TD CLASS="td_name" ROWSPAN="3" TITLE="LastRec">'||recHash.snapdate
              ||'</TD><TD ALIGN="right" TITLE="BufferGets">'||bufgets
              ||'</TD><TD ALIGN="right" TITLE="Executions">'||exe||'</TD>');
        print('<TD ALIGN="right" TITLE="DiskReads">'||diskreads||'</TD><TD ALIGN="right" TITLE="Rows Processed">'
              ||numrows||'</TD><TD ALIGN="right" TITLE="CPUTime">'||cputime
              ||'</TD><TD ALIGN="right" TITLE="Elapsed">'||elapsed||'</TD><TD TITLE="Module">'||module||'</TD></TR>');
--        print('Hash: '||recHash.hashval||', Buffer Gets: '||bufgets||'<br>');
        print('<TR><TD COLSPAN="7">');
        FOR recSQL IN C_GetSQL(recHash.hashval) LOOP
          print(recSQL.sql_text);
        END LOOP;
        print('</TD></TR>');
        get_plan(recHash.hashval);
      END LOOP;
      print(TABLE_CLOSE);
    END;    


/* --------------------------------------------------------------------------
   ----------------------------------------------------[ Main Procedures ]---
   -------------------------------------------------------------------------- */

   PROCEDURE set_exclude_owners(ex_own IN VARCHAR2) IS
     BEGIN
       exclude_owners := ex_own;
     END;

/* -----------------------------------------------[ Chart Data retrieval ]--- */
  PROCEDURE chart_data(start_id IN NUMBER := 0, end_id IN NUMBER := 0, max_chart_interval IN NUMBER := 14) IS
    BEGIN
      init;
      eval_EID(end_id);
      eval_DBUP_ID;
      eval_BID(start_id,max_chart_interval);
      eval_common;
       -- General variables
      print('var bid   = '||bid||';');
      print('var eid   = '||eid||';');
      print('var btime = "'||BTIME||'";');
      print('var etime = "'||ETIME||'";');
      print('var dbup_id = '||DBUP_ID||';');
      print('var amaxval = new Array();');
      print('var amaxdelta = new Array();');
      print('var amaxavedelta = new Array();');
      -- Chart statistics
      get_sysevent('free buffer waits','freebuff');
      get_sysevent('buffer busy waits','busybuff');
      get_sysevent('db file sequential read','fileseq');
      get_sysevent('db file scattered read','filescat');
      get_sysevent('enqueue','enq');
      get_sysevent('LGWR wait for redo copy','lgwr');
      get_sysevent('log file switch completion','lgsw');
      get_sysevent('log file switch (checkpoint incomplete)','ckpt');
      get_sysstat('redo log space requests','redoreq');
      get_sysstat('redo buffer allocation retries','redoret');
      get_sysstat_per('enqueue timeouts','enqueue requests','enqper',1);
      get_sysstat_per('free buffer inspected','free buffer requested','fbp',1);
      get_sysstat_per('table fetch continued row','table fetch by rowid','cfr',100);
      get_libmiss('libmiss');
      get_sysstat('logons current','logon');
      get_sesstat('opened cursors current','opencur');
      get_librpp('rpp');
      get_libghr('ghr');
      get_rowcacheratio('rcr');
      get_filereads('phyrd');
      get_filewrites('phywrt');
      get_sysstat2_ps('user commits','transaction rollbacks','tx');
    END;

/* ------------------------------------------------[ Plan Data retrieval ]--- */
  PROCEDURE fts_plan(start_id IN NUMBER := 0, end_id IN NUMBER := 0, max_plan_interval IN NUMBER := 0) IS
    BEGIN
      init;
      eval_EID(end_id);
      eval_DBUP_ID;
      eval_BID(start_id,max_plan_interval);
      eval_common;
      plan_table;
    END;

END osprep;
/
