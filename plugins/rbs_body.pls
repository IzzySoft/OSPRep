  -- Cache Stats
  IF MK_RSSTAT + MK_RSSTOR > 0 THEN
    print('<A NAME="rbs"></A>');
    IF MK_RSSTAT = 1 THEN
      rbs_stat;
    END IF;
    IF MK_RSSTOR = 1 THEN
      rbs_stor;
    END IF;
    print('<HR>');
  END IF;
