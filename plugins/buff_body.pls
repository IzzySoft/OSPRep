  -- Buffer Pool and Buffer Waits
  IF MK_SPSTAT = 1 THEN
    spstat;
  END IF;
  print('<A NAME="buffstat"></A>');
  IF MK_BUFFP = 1 THEN
    buffp;
  END IF;
  IF MK_BUFFW = 1 THEN
    buffw;
  END IF;
  print('<HR>');
