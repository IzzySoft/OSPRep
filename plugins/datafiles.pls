  -- Datafile Statistics
  S1 := 'istats$datafiles'; I1 := 1; I2 := 0;
  tab_exists(S1,I1,I2);
  IF I2 = 1
  THEN
    get_filestats(DBID,INST_NUM,BID,EID);
  END IF;

