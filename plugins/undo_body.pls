  -- Undo Segs Summary & Stats
  IF MK_USS + MK_USSTAT > 0 THEN
    print('<A NAME="undo"></A>');
    IF MK_USS = 1 THEN
      undosum;
    END IF;
    IF MK_USSTAT = 1 THEN
      undostats;
    END IF;
  END IF;
  print('<HR>');
