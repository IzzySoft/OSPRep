  -- PGA Aggreg Target Memory and PGA Memory Stats
  IF MK_PGAA + MK_PGAM > 0 THEN
    print('<A NAME="rbs"></A>');
    IF MK_PGAA = 1 THEN
      pgaa;
    END IF;
    IF MK_PGAM = 1 THEN
      pgam;
    END IF;
    print('<HR>');
  END IF;
