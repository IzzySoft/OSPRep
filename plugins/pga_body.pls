  -- PGA Aggreg Target Memory and PGA Memory Stats
  IF MK_PGAA + MK_PGAM > 0 THEN
    print('<A NAME="pga"></A>');
    IF MK_PGAA = 1 THEN
      pgaa;
      pgat;
    END IF;
    IF MK_PGAM = 1 THEN
      pgam;
    END IF;
    print('<HR>');
  END IF;
