  -- Undo Segment Stats
  sga_sum;
  IF MK_SGABREAK = 1 THEN
    sga_break;
  END IF;
  print('<HR>');
