  -- TS and File I/O
  SELECT TO_NUMBER(value) INTO I1
    FROM stats$parameter
   WHERE name='db_file_multiblock_read_count'
     AND snap_id = EID
     AND dbid    = DBID
     AND instance_number = INST_NUM;

  print('<A NAME="fileio"></A>');
  IF MK_TSIO = 1 THEN
    tsio;
  END IF;
  IF MK_FIO = 1 THEN
    fio;
  END IF;
  print('<HR>');
