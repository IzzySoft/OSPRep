  -- Cache Stats
  IF MK_DC = 1 THEN
    dictcache;
  END IF;
  IF MK_LC = 1 THEN
    libcache;
  END IF;
  IF MK_DC + MK_LC > 0 THEN
    print('<HR>');
  END IF;
